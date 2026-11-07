module tb;
  typedef enum logic [1:0] {RED, GREEN, BLUE} color_e;
  initial begin
    real    r;
    int     i;
    byte    b;
    color_e c;
    r = 3.75;
    i = int'(r);          // real -> int, rounds to nearest
    b = byte'(300);       // keeps low 8 bits: 300 & 255
    c = color_e'(2);      // numeric value -> enum member
    $display("int'(3.75)  = %0d", i);
    $display("byte'(300)  = %0d", b);
    $display("color_e'(2) = %s", c.name());
    $finish;
  end
endmodule
