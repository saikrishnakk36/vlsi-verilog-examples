// axi_lite_slave_strb.v -- AXI4-Lite slave that honors WSTRB byte lanes
module axi_lite_slave_strb #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input  wire                     ACLK,
    input  wire                     ARESETN,
    input  wire [ADDR_WIDTH-1:0]    AWADDR,
    input  wire                     AWVALID,
    output reg                      AWREADY,
    input  wire [DATA_WIDTH-1:0]    WDATA,
    input  wire [DATA_WIDTH/8-1:0]  WSTRB,
    input  wire                     WVALID,
    output reg                      WREADY,
    output reg  [1:0]               BRESP,
    output reg                      BVALID,
    input  wire                     BREADY,
    input  wire [ADDR_WIDTH-1:0]    ARADDR,
    input  wire                     ARVALID,
    output reg                      ARREADY,
    output reg  [DATA_WIDTH-1:0]    RDATA,
    output reg  [1:0]               RRESP,
    output reg                      RVALID,
    input  wire                     RREADY
);
    localparam OKAY = 2'b00;
    reg [DATA_WIDTH-1:0] regbank [0:3];
    reg [ADDR_WIDTH-1:0] araddr_q;
    integer i, b;

    // Write address + data accepted together
    always @(posedge ACLK) begin
        if (!ARESETN) AWREADY <= 1'b0;
        else if (!AWREADY && AWVALID && WVALID) AWREADY <= 1'b1;
        else AWREADY <= 1'b0;
    end

    always @(posedge ACLK) begin
        if (!ARESETN) begin
            WREADY <= 1'b0;
            for (i = 0; i < 4; i = i + 1) regbank[i] <= {DATA_WIDTH{1'b0}};
        end else if (!WREADY && WVALID && AWVALID) begin
            WREADY <= 1'b1;
            // Only update byte lanes whose strobe bit is set
            for (b = 0; b < DATA_WIDTH/8; b = b + 1)
                if (WSTRB[b])
                    regbank[AWADDR[3:2]][b*8 +: 8] <= WDATA[b*8 +: 8];
        end else begin
            WREADY <= 1'b0;
        end
    end

    always @(posedge ACLK) begin
        if (!ARESETN) begin BVALID <= 1'b0; BRESP <= OKAY; end
        else if (AWREADY && WREADY && !BVALID) begin BVALID <= 1'b1; BRESP <= OKAY; end
        else if (BVALID && BREADY) BVALID <= 1'b0;
    end

    always @(posedge ACLK) begin
        if (!ARESETN) begin ARREADY <= 1'b0; araddr_q <= 0; end
        else if (!ARREADY && ARVALID && !RVALID) begin ARREADY <= 1'b1; araddr_q <= ARADDR; end
        else ARREADY <= 1'b0;
    end

    always @(posedge ACLK) begin
        if (!ARESETN) begin RVALID <= 1'b0; RRESP <= OKAY; RDATA <= 0; end
        else if (ARREADY && !RVALID) begin
            RVALID <= 1'b1; RRESP <= OKAY; RDATA <= regbank[araddr_q[3:2]];
        end else if (RVALID && RREADY) RVALID <= 1'b0;
    end
endmodule

// ---------------- Testbench: full write, then a single-byte write ----------------
module tb_strb;
    reg         ACLK, ARESETN;
    reg  [3:0]  AWADDR, ARADDR;
    reg  [31:0] WDATA;
    reg  [3:0]  WSTRB;
    reg         AWVALID, WVALID, BREADY, ARVALID, RREADY;
    wire        AWREADY, WREADY, BVALID, ARREADY, RVALID;
    wire [1:0]  BRESP, RRESP;
    wire [31:0] RDATA;

    axi_lite_slave_strb dut (
        .ACLK(ACLK), .ARESETN(ARESETN),
        .AWADDR(AWADDR), .AWVALID(AWVALID), .AWREADY(AWREADY),
        .WDATA(WDATA), .WSTRB(WSTRB), .WVALID(WVALID), .WREADY(WREADY),
        .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),
        .ARADDR(ARADDR), .ARVALID(ARVALID), .ARREADY(ARREADY),
        .RDATA(RDATA), .RRESP(RRESP), .RVALID(RVALID), .RREADY(RREADY)
    );

    always #5 ACLK = ~ACLK;

    // Simple blocking-task write/read helpers
    task axi_write(input [3:0] addr, input [31:0] data, input [3:0] strb);
        begin
            AWADDR=addr; WDATA=data; WSTRB=strb;
            AWVALID=1; WVALID=1; BREADY=1;
            wait (AWREADY && WREADY); @(posedge ACLK);
            AWVALID=0; WVALID=0;
            wait (BVALID); @(posedge ACLK);
            BREADY=0; @(posedge ACLK);
        end
    endtask

    task axi_read(input [3:0] addr);
        begin
            ARADDR=addr; ARVALID=1; RREADY=1;
            wait (ARREADY); @(posedge ACLK);
            ARVALID=0;
            wait (RVALID);
            $display("[%0t] READ  addr=0x%0h data=0x%08h", $time, addr, RDATA);
            @(posedge ACLK); RREADY=0; @(posedge ACLK);
        end
    endtask

    initial begin
        ACLK=0; ARESETN=0;
        AWADDR=0; WDATA=0; WSTRB=4'hF;
        AWVALID=0; WVALID=0; BREADY=0; ARADDR=0; ARVALID=0; RREADY=0;
        repeat (2) @(posedge ACLK);
        ARESETN=1; @(posedge ACLK);

        // Full 32-bit write of 0x11223344 to register 0
        axi_write(4'h0, 32'h1122_3344, 4'b1111);
        axi_read (4'h0);

        // Write only the least-significant byte (strobe 0001) with 0xFF
        axi_write(4'h0, 32'h0000_00FF, 4'b0001);
        axi_read (4'h0);

        if (RDATA === 32'h1122_33FF)
            $display("RESULT: PASS - only byte 0 changed (0x112233FF)");
        else
            $display("RESULT: FAIL - got 0x%08h", RDATA);
        $finish;
    end
endmodule
