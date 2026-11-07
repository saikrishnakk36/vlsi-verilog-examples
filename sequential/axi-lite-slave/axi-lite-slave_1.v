// axi_lite_slave.v  -- AXI4-Lite slave with a 4-word register bank
module axi_lite_slave #(
    parameter ADDR_WIDTH = 4,   // 4 bits -> 16 bytes -> 4 words
    parameter DATA_WIDTH = 32
)(
    input  wire                     ACLK,
    input  wire                     ARESETN,   // active-low reset

    // Write address channel
    input  wire [ADDR_WIDTH-1:0]    AWADDR,
    input  wire                     AWVALID,
    output reg                      AWREADY,

    // Write data channel
    input  wire [DATA_WIDTH-1:0]    WDATA,
    input  wire [DATA_WIDTH/8-1:0]  WSTRB,
    input  wire                     WVALID,
    output reg                      WREADY,

    // Write response channel
    output reg  [1:0]               BRESP,
    output reg                      BVALID,
    input  wire                     BREADY,

    // Read address channel
    input  wire [ADDR_WIDTH-1:0]    ARADDR,
    input  wire                     ARVALID,
    output reg                      ARREADY,

    // Read data channel
    output reg  [DATA_WIDTH-1:0]    RDATA,
    output reg  [1:0]               RRESP,
    output reg                      RVALID,
    input  wire                     RREADY
);
    localparam OKAY = 2'b00;

    // Register bank: 4 x 32-bit
    reg [DATA_WIDTH-1:0] regbank [0:3];
    reg [ADDR_WIDTH-1:0] awaddr_q;   // latched write address
    reg [ADDR_WIDTH-1:0] araddr_q;   // latched read address
    integer i;

    // ---- Write address handshake ----
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            AWREADY  <= 1'b0;
            awaddr_q <= {ADDR_WIDTH{1'b0}};
        end else if (!AWREADY && AWVALID && WVALID) begin
            AWREADY  <= 1'b1;        // accept address when both valids are up
            awaddr_q <= AWADDR;
        end else begin
            AWREADY  <= 1'b0;
        end
    end

    // ---- Write data handshake + register update ----
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            WREADY <= 1'b0;
            for (i = 0; i < 4; i = i + 1)
                regbank[i] <= {DATA_WIDTH{1'b0}};
        end else if (!WREADY && WVALID && AWVALID) begin
            WREADY <= 1'b1;          // accept data in the same cycle as address
            regbank[AWADDR[3:2]] <= WDATA;
        end else begin
            WREADY <= 1'b0;
        end
    end

    // ---- Write response channel ----
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            BVALID <= 1'b0;
            BRESP  <= OKAY;
        end else if (AWREADY && WREADY && !BVALID) begin
            BVALID <= 1'b1;          // one response per write
            BRESP  <= OKAY;
        end else if (BVALID && BREADY) begin
            BVALID <= 1'b0;          // master took the response
        end
    end

    // ---- Read address handshake (latch the address on accept) ----
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            ARREADY  <= 1'b0;
            araddr_q <= {ADDR_WIDTH{1'b0}};
        end else if (!ARREADY && ARVALID && !RVALID) begin
            ARREADY  <= 1'b1;
            araddr_q <= ARADDR;
        end else begin
            ARREADY  <= 1'b0;
        end
    end

    // ---- Read data channel (keyed off ARREADY, not the master's ARVALID) ----
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            RVALID <= 1'b0;
            RRESP  <= OKAY;
            RDATA  <= {DATA_WIDTH{1'b0}};
        end else if (ARREADY && !RVALID) begin
            RVALID <= 1'b1;
            RRESP  <= OKAY;
            RDATA  <= regbank[araddr_q[3:2]];
        end else if (RVALID && RREADY) begin
            RVALID <= 1'b0;          // master took the data
        end
    end
endmodule

// ---------------- Testbench: one write then one read ----------------
module tb_axi_lite;
    reg         ACLK, ARESETN;
    reg  [3:0]  AWADDR, ARADDR;
    reg  [31:0] WDATA;
    reg  [3:0]  WSTRB;
    reg         AWVALID, WVALID, BREADY, ARVALID, RREADY;
    wire        AWREADY, WREADY, BVALID, ARREADY, RVALID;
    wire [1:0]  BRESP, RRESP;
    wire [31:0] RDATA;

    axi_lite_slave dut (
        .ACLK(ACLK), .ARESETN(ARESETN),
        .AWADDR(AWADDR), .AWVALID(AWVALID), .AWREADY(AWREADY),
        .WDATA(WDATA), .WSTRB(WSTRB), .WVALID(WVALID), .WREADY(WREADY),
        .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),
        .ARADDR(ARADDR), .ARVALID(ARVALID), .ARREADY(ARREADY),
        .RDATA(RDATA), .RRESP(RRESP), .RVALID(RVALID), .RREADY(RREADY)
    );

    // 100 MHz clock (period = 10 time units)
    always #5 ACLK = ~ACLK;

    initial begin
        // init
        ACLK = 0; ARESETN = 0;
        AWADDR = 0; WDATA = 0; WSTRB = 4'hF;
        AWVALID = 0; WVALID = 0; BREADY = 0;
        ARADDR = 0; ARVALID = 0; RREADY = 0;

        // hold reset for 2 clocks
        repeat (2) @(posedge ACLK);
        ARESETN = 1;
        @(posedge ACLK);

        // ---- WRITE 32'hDEAD_BEEF to register 1 (byte addr 0x4) ----
        AWADDR  = 4'h4; WDATA = 32'hDEAD_BEEF;
        AWVALID = 1;    WVALID = 1; BREADY = 1;
        // wait until both address and data are accepted
        wait (AWREADY && WREADY); @(posedge ACLK);
        AWVALID = 0; WVALID = 0;
        // wait for the write response
        wait (BVALID); @(posedge ACLK);
        BREADY = 0;
        $display("[%0t] WRITE  addr=0x%0h data=0x%08h BRESP=%b", $time, 4'h4, 32'hDEAD_BEEF, BRESP);

        @(posedge ACLK);

        // ---- READ back register 1 ----
        ARADDR = 4'h4; ARVALID = 1; RREADY = 1;
        wait (ARREADY); @(posedge ACLK);
        ARVALID = 0;
        wait (RVALID);
        $display("[%0t] READ   addr=0x%0h data=0x%08h RRESP=%b", $time, 4'h4, RDATA, RRESP);
        if (RDATA === 32'hDEAD_BEEF)
            $display("RESULT: PASS - read value matches written value");
        else
            $display("RESULT: FAIL - expected 0xDEADBEEF got 0x%08h", RDATA);
        @(posedge ACLK);
        RREADY = 0;

        @(posedge ACLK);
        $finish;
    end
endmodule
