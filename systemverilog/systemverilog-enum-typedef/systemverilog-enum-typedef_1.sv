module tb;
  typedef enum logic [1:0] {RED, GREEN, YELLOW} light_t;
  light_t sig, tmp;

  initial begin
    sig = GREEN;
    $display("value    = %0d", sig);
    $display("name     = %s", sig.name());
    tmp = sig.first();
    $display("first    = %s", tmp.name());
    tmp = sig.last();
    $display("last     = %s", tmp.name());
    tmp = sig.next();
    $display("next     = %s", tmp.name());
    $display("num      = %0d", sig.num());
    sig = YELLOW;
    tmp = sig.next();
    $display("wrap-next= %s", tmp.name());
    $finish;
  end
endmodule
