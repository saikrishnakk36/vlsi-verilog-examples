module tb;
  string pkts[$];   // a queue of strings
  int i;

  initial begin
    pkts = {"A", "B", "C"};     // assign a whole queue at once
    pkts.insert(1, "X");        // insert "X" at index 1 -> {A, X, B, C}
    $display("after insert:");
    foreach (pkts[i])
      $display("  pkts[%0d] = %s", i, pkts[i]);

    pkts.delete(2);             // delete index 2 -> {A, X, C}
    $display("after delete(2):");
    foreach (pkts[i])
      $display("  pkts[%0d] = %s", i, pkts[i]);

    pkts.delete();              // delete the whole queue
    $display("after delete() : size = %0d", pkts.size());
    $finish;
  end
endmodule
