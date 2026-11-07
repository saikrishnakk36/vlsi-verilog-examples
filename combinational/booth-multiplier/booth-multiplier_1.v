// booth_mult.v  --  Sequential radix-2 Booth multiplier (parameterized, signed)
module booth_mult #(parameter WIDTH = 4) (
    input  wire                      clk,
    input  wire                      rst,    // synchronous, active-high
    input  wire                      start,  // pulse high to begin a multiply
    input  wire signed [WIDTH-1:0]   a,      // multiplicand
    input  wire signed [WIDTH-1:0]   b,      // multiplier
    output reg  signed [2*WIDTH-1:0] p,      // signed product (valid when done=1)
    output reg                       done    // 1-cycle completion strobe
);
    localparam CW = $clog2(WIDTH) + 1;

    reg signed [2*WIDTH+1:0] acc;    // {A[WIDTH+1], Q[WIDTH], Q_1[1]}
    reg signed [2*WIDTH+1:0] nxt;    // next-state (blocking temp)
    reg signed [WIDTH:0]     m_ext;  // multiplicand, sign-extended by 1 bit
    reg        [CW-1:0]      count;
    reg                      busy;

    always @(posedge clk) begin
        if (rst) begin
            busy <= 1'b0;
            done <= 1'b0;
            p    <= {(2*WIDTH){1'b0}};
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                acc   <= {{(WIDTH+1){1'b0}}, b, 1'b0};   // A=0, Q=b, Q_1=0
                m_ext <= {a[WIDTH-1], a};                // sign-extend multiplicand
                count <= WIDTH[CW-1:0];
                busy  <= 1'b1;
            end else if (busy) begin
                nxt = acc;                               // start from current state
                case (acc[1:0])                          // Booth bits = {Q[0], Q_1}
                    2'b01: nxt[2*WIDTH+1:WIDTH+1] = acc[2*WIDTH+1:WIDTH+1] + m_ext;
                    2'b10: nxt[2*WIDTH+1:WIDTH+1] = acc[2*WIDTH+1:WIDTH+1] - m_ext;
                    default: ;                           // 00 / 11: no add/sub
                endcase
                nxt   = nxt >>> 1;                       // arithmetic right shift
                acc   <= nxt;
                count <= count - 1'b1;
                if (count == 1) begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    p    <= nxt[2*WIDTH:1];              // {A,Q} low 2*WIDTH bits
                end
            end
        end
    end
endmodule

// -------- testbench: drive signed cases through the handshake --------
module tb_booth_mult;
    localparam WIDTH = 4;
    reg clk, rst, start;
    reg  signed [WIDTH-1:0]   a, b;
    wire signed [2*WIDTH-1:0] p;
    wire done;

    booth_mult #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .start(start),
        .a(a), .b(b), .p(p), .done(done));

    always #1 clk = ~clk;                // 2 ns period

    reg signed [2*WIDTH-1:0] exp;
    task multiply(input signed [WIDTH-1:0] ai, input signed [WIDTH-1:0] bi);
        begin
            @(negedge clk); a = ai; b = bi; start = 1'b1;
            @(negedge clk); start = 1'b0;
            wait (done == 1'b1);
            @(negedge clk);
            exp = ai * bi;                   // widen in assignment context
            $display("%0d * %0d = %0d  (expected %0d)  %s",
                     ai, bi, p, exp, (p === exp) ? "OK" : "BAD");
        end
    endtask

    initial begin
        clk = 0; rst = 1; start = 0; a = 0; b = 0;
        @(negedge clk); rst = 0;
        multiply( 3,  5);
        multiply(-3,  5);
        multiply( 7, -2);
        multiply(-4, -6);
        multiply(-8,  7);    // most-negative multiplicand
        multiply(-8, -8);    // both most-negative
        $display("done.");
        $finish;
    end
endmodule

