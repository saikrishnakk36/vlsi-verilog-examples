// apb_slave_wait.v -- APB slave that inserts ONE wait state via PREADY
module apb_slave_wait #(
    parameter DATA_WIDTH = 32
)(
    input  wire                   pclk,
    input  wire                   presetn,
    input  wire [7:0]             paddr,
    input  wire                   psel,
    input  wire                   penable,
    input  wire                   pwrite,
    input  wire [DATA_WIDTH-1:0]  pwdata,
    output reg  [DATA_WIDTH-1:0]  prdata,
    output wire                   pready
);
    reg [DATA_WIDTH-1:0] regfile [0:3];
    wire [1:0] index = paddr[3:2];

    // Hold PREADY low for the first ACCESS cycle, high on the next.
    reg wait_done;
    always @(posedge pclk or negedge presetn) begin
        if (!presetn)                 wait_done <= 1'b0;
        else if (psel && penable)     wait_done <= 1'b1;   // ready next cycle
        else                          wait_done <= 1'b0;
    end
    assign pready = psel && penable && wait_done;

    integer i;
    always @(posedge pclk or negedge presetn) begin
        if (!presetn)
            for (i = 0; i < 4; i = i + 1) regfile[i] <= 32'h0;
        else if (psel && penable && pready && pwrite)
            regfile[index] <= pwdata;                       // commit on READY
    end

    always @(*) prdata = (psel && !pwrite) ? regfile[index] : 32'h0;
endmodule

// Testbench: write two registers, read both back, honouring PREADY
module apb_slave_wait_tb;
    reg         pclk, presetn;
    reg  [7:0]  paddr;
    reg         psel, penable, pwrite;
    reg  [31:0] pwdata;
    wire [31:0] prdata;
    wire        pready;

    apb_slave_wait dut (
        .pclk(pclk), .presetn(presetn), .paddr(paddr),
        .psel(psel), .penable(penable), .pwrite(pwrite),
        .pwdata(pwdata), .prdata(prdata), .pready(pready)
    );

    initial pclk = 0;
    always #5 pclk = ~pclk;

    task apb_write(input [7:0] addr, input [31:0] data);
    begin
        @(posedge pclk); paddr <= addr; pwdata <= data;
        pwrite <= 1; psel <= 1; penable <= 0;
        @(posedge pclk); penable <= 1;
        while (!pready) @(posedge pclk);   // stretch for wait states
        @(posedge pclk); psel <= 0; penable <= 0;
        $display("[%0t] WRITE addr=0x%02h data=0x%08h", $time, addr, data);
    end
    endtask

    task apb_read(input [7:0] addr, output [31:0] rd);
    begin
        @(posedge pclk); paddr <= addr; pwrite <= 0; psel <= 1; penable <= 0;
        @(posedge pclk); penable <= 1;
        while (!pready) @(posedge pclk);
        rd = prdata;
        @(posedge pclk); psel <= 0; penable <= 0;
        $display("[%0t] READ  addr=0x%02h data=0x%08h", $time, addr, rd);
    end
    endtask

    reg [31:0] a, b;
    initial begin
        psel=0; penable=0; pwrite=0; paddr=0; pwdata=0; presetn=0;
        repeat (2) @(posedge pclk); presetn = 1;

        apb_write(8'h00, 32'h1234_5678);   // CTRL
        apb_write(8'h0C, 32'hCAFE_0001);   // DATA1
        apb_read (8'h00, a);
        apb_read (8'h0C, b);

        if (a === 32'h1234_5678 && b === 32'hCAFE_0001)
            $display("PASS: both registers read back correctly");
        else
            $display("FAIL: a=0x%08h b=0x%08h", a, b);

        repeat (2) @(posedge pclk);
        $finish;
    end
endmodule
