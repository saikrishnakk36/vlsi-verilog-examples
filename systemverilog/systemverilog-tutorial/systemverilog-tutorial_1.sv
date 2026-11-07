module tb;
  logic [3:0] a;   // 4-state: 0, 1, X, Z
  bit   [3:0] b;   // 2-state: 0 and 1 only

  initial begin
    $display("a uninitialised (logic) = %b", a);
    $display("b uninitialised (bit)   = %b", b);

    a = 4'b1010;
    b = a;
    $display("after assign: a = %0d, b = %0d", a, b);

    a = 4'b10zx;
    $display("a with z/x = %b, read as int = %0d", a, a);

    if (a === 4'b10zx)
      $display("4-state compare (===) sees the z and x");
    $finish;
  end
endmodule
