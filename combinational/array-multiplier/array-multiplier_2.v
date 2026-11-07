// array_mult8.v - same parameterized core, instantiated as 8x8
module cx_fa (input a, input b, input cin, output s, output cout);
  assign s    = a ^ b ^ cin;
  assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module cx_rca #(parameter N = 4) (
  input  [N-1:0] a,
  input  [N-1:0] b,
  input          cin,
  output [N-1:0] sum,
  output         cout
);
  wire [N:0] c;
  assign c[0] = cin;
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : fa_chain
      cx_fa u_fa (.a(a[i]), .b(b[i]), .cin(c[i]), .s(sum[i]), .cout(c[i+1]));
    end
  endgenerate
  assign cout = c[N];
endmodule

module array_multiplier #(parameter N = 4) (
  input  [N-1:0]   a,
  input  [N-1:0]   b,
  output [2*N-1:0] p
);
  wire [N-1:0] pp [0:N-1];
  genvar g;
  generate
    for (g = 0; g < N; g = g + 1) begin : gen_pp
      assign pp[g] = a & {N{b[g]}};
    end
  endgenerate

  wire [N-1:0] acc   [0:N];
  wire [N-1:0] s_row [0:N-1];
  wire         c_row [0:N-1];

  assign acc[0] = {N{1'b0}};

  generate
    for (g = 0; g < N; g = g + 1) begin : gen_rows
      cx_rca #(.N(N)) u_add (
        .a(acc[g]), .b(pp[g]), .cin(1'b0),
        .sum(s_row[g]), .cout(c_row[g])
      );
      assign p[g]     = s_row[g][0];
      assign acc[g+1] = {c_row[g], s_row[g][N-1:1]};
    end
  endgenerate

  assign p[2*N-1:N] = acc[N];
endmodule

module tb_array_multiplier;
  localparam N = 8;
  reg  [N-1:0]   a, b;
  wire [2*N-1:0] p;
  integer i, errors;

  array_multiplier #(.N(N)) dut (.a(a), .b(b), .p(p));

  initial begin
    errors = 0;
    for (i = 0; i < 8; i = i + 1) begin
      a = $random;
      b = $random;
      #5;
      if (p !== (a * b)) begin
        $display("FAIL: %0d x %0d = %0d (expected %0d)", a, b, p, a * b);
        errors = errors + 1;
      end else begin
        $display("PASS: %0d x %0d = %0d", a, b, p);
      end
    end
    // Corner case: full-scale inputs
    a = 8'd255; b = 8'd255; #5;
    if (p !== 16'd65025) begin
      $display("FAIL: 255 x 255 = %0d (expected 65025)", p);
      errors = errors + 1;
    end else begin
      $display("PASS: 255 x 255 = %0d", p);
    end
    if (errors == 0) $display("All tests passed.");
    else             $display("%0d test(s) failed.", errors);
    $finish;
  end
endmodule
