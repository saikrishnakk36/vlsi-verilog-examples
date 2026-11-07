// ex1_immediate.sv  --  immediate assertions check logic right now
module tb;
  logic [3:0] a, b;
  logic [4:0] sum;

  // A tiny combinational "DUT": a 4-bit adder
  assign sum = a + b;

  initial begin
    // Drive a few vectors and check each result immediately.
    a = 4'd3;  b = 4'd4;  #1;
    assert (sum == 5'd7)
      else $error("add failed: %0d + %0d = %0d", a, b, sum);

    a = 4'd15; b = 4'd1;  #1;
    assert (sum == 5'd16)   // carry out into bit 4
      $display("PASS: 15 + 1 = %0d", sum);   // pass action block is optional

    a = 4'd9;  b = 4'd9;  #1;
    assert (sum == 5'd18)
      else $error("add failed: %0d + %0d = %0d", a, b, sum);

    $display("All immediate assertions passed.");
    $finish;
  end
endmodule
