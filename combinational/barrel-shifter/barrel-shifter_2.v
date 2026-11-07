// barrel_behav.v
// Compact behavioral barrel shifter. The synthesizer still infers a
// barrel (log-depth mux tree); this form is shorter to read and adds an
// arithmetic-right mode using a signed cast.
module barrel_behav #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]         data_in,
    input  wire [$clog2(WIDTH)-1:0] shamt,
    input  wire [1:0]               mode,   // 0=log-left 1=log-right 2=rotate-left 3=arith-right
    output reg  [WIDTH-1:0]         data_out
);
    wire signed [WIDTH-1:0] s_in = data_in;
    always @(*) begin
        case (mode)
            2'd0: data_out = data_in << shamt;                       // logical left
            2'd1: data_out = data_in >> shamt;                       // logical right
            2'd2: data_out = (data_in << shamt) |                    // rotate left
                             (data_in >> (WIDTH - shamt));
            2'd3: data_out = s_in >>> shamt;                         // arithmetic right
            default: data_out = data_in;
        endcase
    end
endmodule

// tb_barrel_behav.v
// Drives all four modes and prints each result with $monitor-style output.
module tb_barrel_behav;
    localparam WIDTH   = 8;
    localparam SHIFT_W = $clog2(WIDTH);

    reg  [WIDTH-1:0]   data_in;
    reg  [SHIFT_W-1:0] shamt;
    reg  [1:0]         mode;
    wire [WIDTH-1:0]   data_out;

    barrel_behav #(.WIDTH(WIDTH)) dut (
        .data_in (data_in),
        .shamt   (shamt),
        .mode    (mode),
        .data_out(data_out)
    );

    initial begin
        $display("== Behavioral barrel shifter, 4 modes ==");
        data_in = 8'b1011_0001; shamt = 3;

        mode = 2'd0; #1 $display("log-left   by %0d : %b -> %b", shamt, data_in, data_out);
        mode = 2'd1; #1 $display("log-right  by %0d : %b -> %b", shamt, data_in, data_out);
        mode = 2'd2; #1 $display("rotate-left by %0d : %b -> %b", shamt, data_in, data_out);
        mode = 2'd3; #1 $display("arith-right by %0d : %b -> %b", shamt, data_in, data_out);

        data_in = 8'b0100_1111; shamt = 2;
        mode = 2'd3; #1 $display("arith-right by %0d : %b -> %b (MSB=0)", shamt, data_in, data_out);

        $finish;
    end
endmodule

