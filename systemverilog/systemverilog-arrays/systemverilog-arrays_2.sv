module tb;
  int dyn [];
  initial begin
    dyn = new[4];
    foreach (dyn[i]) dyn[i] = i*i;
    $write("after new[4]  size=%0d :", dyn.size());
    foreach (dyn[i]) $write(" %0d", dyn[i]);
    $write("n");
    dyn = new[6](dyn);
    dyn[4] = 100; dyn[5] = 200;
    $write("after new[6]  size=%0d :", dyn.size());
    foreach (dyn[i]) $write(" %0d", dyn[i]);
    $write("n");
    dyn.delete();
    $display("after delete  size=%0d", dyn.size());
    $finish;
  end
endmodule
