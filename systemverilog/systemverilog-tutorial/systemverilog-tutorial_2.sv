// Device under test: a parameterised unsigned adder
module adder #(parameter int W = 4) (
  input  logic [W-1:0] a,
  input  logic [W-1:0] b,
  output logic [W:0]   sum
);
  assign sum = a + b;
endmodule

// Self-checking testbench
module tb;
  logic [3:0] a, b;
  logic [4:0] sum;
  int errors = 0;

  adder #(.W(4)) dut (.a(a), .b(b), .sum(sum));

  task automatic apply(input logic [3:0] x, input logic [3:0] y);
    a = x; b = y;
    #1;                               // let the combinational logic settle
    if (sum !== (x + y)) begin
      $display("FAIL: %0d + %0d -> %0d (expected %0d)", x, y, sum, x + y);
      errors++;
    end else begin
      $display("PASS: %0d + %0d = %0d", x, y, sum);
    end
  endtask

  initial begin
    apply(4'd3,  4'd4);
    apply(4'd15, 4'd1);               // carry into bit 4
    apply(4'd9,  4'd9);
    if (errors == 0) $display("RESULT: all vectors passed");
    else             $display("RESULT: %0d vector(s) failed", errors);
    $finish;
  end
endmodule
