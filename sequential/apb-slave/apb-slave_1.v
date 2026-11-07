// apb_slave.v  --  APB3 slave with a 4-register map
// Zero-wait-state: PREADY is always high.
module apb_slave #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  wire                   pclk,
    input  wire                   presetn,   // active-low reset
    input  wire [ADDR_WIDTH-1:0]  paddr,
    input  wire                   psel,
    input  wire                   penable,
    input  wire                   pwrite,
    input  wire [DATA_WIDTH-1:0]  pwdata,
    output reg  [DATA_WIDTH-1:0]  prdata,
    output wire                   pready
);
    // Four 32-bit registers decoded from paddr[3:2]:
    //   0x00 CTRL, 0x04 STATUS, 0x08 DATA0, 0x0C DATA1
    reg [DATA_WIDTH-1:0] regfile [0:3];
    wire [1:0] index = paddr[3:2];

    assign pready = 1'b1;                     // no wait states

    // Write happens only in the ACCESS phase (PSEL & PENABLE & PWRITE)
    integer i;
    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            for (i = 0; i < 4; i = i + 1)
                regfile[i] <= {DATA_WIDTH{1'b0}};
        end else if (psel && penable && pwrite) begin
            regfile[index] <= pwdata;
        end
    end

    // Read is combinational: drive PRDATA whenever selected for a read
    always @(*) begin
        if (psel && !pwrite)
            prdata = regfile[index];
        else
            prdata = {DATA_WIDTH{1'b0}};
    end
endmodule

// ---------------------------------------------------------------
// Testbench: drive one APB write, then one APB read, to the slave
// ---------------------------------------------------------------
module apb_slave_tb;
    reg         pclk, presetn;
    reg  [7:0]  paddr;
    reg         psel, penable, pwrite;
    reg  [31:0] pwdata;
    wire [31:0] prdata;
    wire        pready;

    apb_slave dut (
        .pclk(pclk), .presetn(presetn), .paddr(paddr),
        .psel(psel), .penable(penable), .pwrite(pwrite),
        .pwdata(pwdata), .prdata(prdata), .pready(pready)
    );

    // 10 ns clock
    initial pclk = 1'b0;
    always #5 pclk = ~pclk;

    // One APB write transfer (SETUP then ACCESS)
    task apb_write(input [7:0] addr, input [31:0] data);
    begin
        @(posedge pclk);                  // SETUP phase
        paddr <= addr; pwdata <= data;
        pwrite <= 1'b1; psel <= 1'b1; penable <= 1'b0;
        @(posedge pclk);                  // ACCESS phase
        penable <= 1'b1;
        @(posedge pclk);                  // slave samples here
        psel <= 1'b0; penable <= 1'b0;
        $display("[%0t] WRITE addr=0x%02h data=0x%08h", $time, addr, data);
    end
    endtask

    // One APB read transfer; returns captured data in rd
    task apb_read(input [7:0] addr, output [31:0] rd);
    begin
        @(posedge pclk);                  // SETUP phase
        paddr <= addr; pwrite <= 1'b0;
        psel <= 1'b1; penable <= 1'b0;
        @(posedge pclk);                  // ACCESS phase
        penable <= 1'b1;
        #1 rd = prdata;                   // sample data in ACCESS phase
        @(posedge pclk);
        psel <= 1'b0; penable <= 1'b0;
        $display("[%0t] READ  addr=0x%02h data=0x%08h", $time, addr, rd);
    end
    endtask

    reg [31:0] got;
    initial begin
        // init + reset
        psel = 0; penable = 0; pwrite = 0; paddr = 0; pwdata = 0;
        presetn = 0;
        repeat (2) @(posedge pclk);
        presetn = 1;

        apb_write(8'h08, 32'hDEAD_BEEF);  // write DATA0
        apb_read (8'h08, got);            // read it back
        if (got === 32'hDEAD_BEEF)
            $display("PASS: read-back matches written value");
        else
            $display("FAIL: expected 0xDEADBEEF got 0x%08h", got);

        repeat (2) @(posedge pclk);
        $finish;
    end
endmodule
