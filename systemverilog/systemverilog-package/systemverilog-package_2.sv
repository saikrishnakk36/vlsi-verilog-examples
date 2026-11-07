package alu_pkg;
  parameter int WIDTH = 4;
  function automatic logic [WIDTH-1:0] add_sat(logic [WIDTH-1:0] a, b);
    logic [WIDTH:0] sum = a + b;                 // one extra bit
    return sum[WIDTH] ? '1 : sum[WIDTH-1:0];     // saturate on overflow
  endfunction
endpackage

package fmt_pkg;
  parameter int WIDTH = 8;    // deliberately different WIDTH
  function automatic int to_decimal(logic [WIDTH-1:0] v);
    return int'(v);
  endfunction
endpackage

module tb;
  import alu_pkg::add_sat;     // bring one function into scope
  import alu_pkg::WIDTH;       // use alu_pkg's WIDTH unqualified

  logic [WIDTH-1:0] r;

  initial begin
    r = add_sat(4'd9, 4'd12);                 // 21 -> saturates to 15
    $display("saturated sum      = %0d", r);
    // scope resolution :: reaches fmt_pkg without importing it
    $display("fmt_pkg::WIDTH     = %0d", fmt_pkg::WIDTH);
    $display("decimal of 8'hA5   = %0d", fmt_pkg::to_decimal(8'hA5));
    $finish;
  end
endmodule
