// uart_loopback.v  -- parameterized UART TX + RX, wired back-to-back
// Build & run:  iverilog -g2005 -o sim uart_loopback.v && vvp sim

module uart_tx #(parameter integer CLKS_PER_BIT = 8, parameter integer DATA_BITS = 8) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 start,       // 1-cycle pulse: latch tx_data and send
    input  wire [DATA_BITS-1:0] tx_data,
    output reg                  tx,          // serial line, idles high
    output reg                  busy,
    output reg                  done         // 1-cycle pulse at end of stop bit
);
    localparam [1:0] IDLE=2'd0, START=2'd1, DATA=2'd2, STOP=2'd3;
    localparam integer CW = (CLKS_PER_BIT < 2) ? 1 : $clog2(CLKS_PER_BIT);
    localparam integer BW = (DATA_BITS    < 2) ? 1 : $clog2(DATA_BITS);
    reg [1:0] state;  reg [CW-1:0] cnt;  reg [BW-1:0] idx;  reg [DATA_BITS-1:0] sh;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=IDLE; tx<=1'b1; busy<=1'b0; done<=1'b0;
            cnt<=0; idx<=0; sh<=0;
        end else begin
            done <= 1'b0;
            case (state)
            IDLE:  begin tx<=1'b1; cnt<=0; idx<=0;
                         if (start) begin sh<=tx_data; busy<=1'b1; state<=START; end end
            START: begin tx<=1'b0;                       // start bit
                         if (cnt==CLKS_PER_BIT-1) begin cnt<=0; state<=DATA; end
                         else cnt<=cnt+1'b1; end
            DATA:  begin tx<=sh[idx];                     // 8 data bits, LSB first
                         if (cnt==CLKS_PER_BIT-1) begin cnt<=0;
                             if (idx==DATA_BITS-1) begin idx<=0; state<=STOP; end
                             else idx<=idx+1'b1;
                         end else cnt<=cnt+1'b1; end
            STOP:  begin tx<=1'b1;                        // stop bit
                         if (cnt==CLKS_PER_BIT-1) begin cnt<=0; busy<=1'b0; done<=1'b1; state<=IDLE; end
                         else cnt<=cnt+1'b1; end
            endcase
        end
    end
endmodule

module uart_rx #(parameter integer CLKS_PER_BIT = 8, parameter integer DATA_BITS = 8) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 rx,          // async serial input
    output reg [DATA_BITS-1:0]  rx_data,
    output reg                  valid        // 1-cycle pulse when byte is ready
);
    localparam [1:0] IDLE=2'd0, START=2'd1, DATA=2'd2, STOP=2'd3;
    localparam integer CW = (CLKS_PER_BIT < 2) ? 1 : $clog2(CLKS_PER_BIT);
    localparam integer BW = (DATA_BITS    < 2) ? 1 : $clog2(DATA_BITS);
    reg s1, s2;                               // 2-flop synchronizer
    reg [1:0] state;  reg [CW-1:0] cnt;  reg [BW-1:0] idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin s1<=1'b1; s2<=1'b1; end
        else        begin s1<=rx;   s2<=s1;   end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state<=IDLE; cnt<=0; idx<=0; rx_data<=0; valid<=1'b0; end
        else begin
            valid <= 1'b0;
            case (state)
            IDLE:  begin cnt<=0; idx<=0; if (s2==1'b0) state<=START; end
            START: begin                                  // confirm start at its centre
                       if (cnt==(CLKS_PER_BIT-1)/2) begin
                           if (s2==1'b0) begin cnt<=0; state<=DATA; end
                           else state<=IDLE;              // glitch, not a real start
                       end else cnt<=cnt+1'b1; end
            DATA:  begin                                  // sample each bit at its centre
                       if (cnt==CLKS_PER_BIT-1) begin cnt<=0; rx_data[idx]<=s2;
                           if (idx==DATA_BITS-1) begin idx<=0; state<=STOP; end
                           else idx<=idx+1'b1;
                       end else cnt<=cnt+1'b1; end
            STOP:  begin
                       if (cnt==CLKS_PER_BIT-1) begin cnt<=0; valid<=1'b1; state<=IDLE; end
                       else cnt<=cnt+1'b1; end
            endcase
        end
    end
endmodule

module tb_uart_loopback;
    localparam integer CLKS_PER_BIT = 8, DATA_BITS = 8;
    reg clk=1'b0, rst_n=1'b0, start=1'b0;
    reg  [DATA_BITS-1:0] tx_data=0;
    wire line, busy, done, valid;
    wire [DATA_BITS-1:0] rx_data;
    integer errors = 0;

    uart_tx #(CLKS_PER_BIT, DATA_BITS) TX (.clk(clk),.rst_n(rst_n),.start(start),
        .tx_data(tx_data),.tx(line),.busy(busy),.done(done));
    uart_rx #(CLKS_PER_BIT, DATA_BITS) RX (.clk(clk),.rst_n(rst_n),.rx(line),
        .rx_data(rx_data),.valid(valid));

    always #5 clk = ~clk;                      // 100 MHz

    task send_and_check(input [DATA_BITS-1:0] b);
        begin
            @(posedge clk); tx_data=b; start=1'b1;
            @(posedge clk); start=1'b0;
            @(posedge valid); @(posedge clk);
            if (rx_data===b)
                $display("[%0t] sent 0x%02h -> received 0x%02h  OK", $time, b, rx_data);
            else begin
                $display("[%0t] sent 0x%02h -> received 0x%02h  MISMATCH", $time, b, rx_data);
                errors = errors + 1;
            end
            repeat (2*CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    initial begin
        $display("UART loopback, CLKS_PER_BIT=%0d, %0d data bits", CLKS_PER_BIT, DATA_BITS);
        repeat (3) @(posedge clk); rst_n = 1'b1;
        send_and_check(8'h55);
        send_and_check(8'hA5);
        send_and_check(8'h3C);
        if (errors==0) $display("LOOPBACK PASS: all bytes matched");
        else           $display("LOOPBACK FAIL: %0d mismatch(es)", errors);
        $finish;
    end
endmodule
