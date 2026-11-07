module tb;
  initial begin
    logic [3:0] v;
    v = 4'b1100;
    $display("plain bits          = %0d", v);
    $display("signed cast value   = %0d", signed'(v));
    $display("unsigned cast value = %0d", unsigned'(signed'(v)));
    $finish;
  end
endmodule
