module tb;
  int scores[$] = {40, 90, 15, 72, 90};
  int top[$];      // max() and find() return queues, not scalars
  int low[$];
  int passed[$];
  int idx[$];

  initial begin
    // Reduction method: sum() collapses the queue to one value
    $display("sum of all scores = %0d", scores.sum());

    // Locator methods max()/min() return a 1-element queue
    top = scores.max();
    low = scores.min();
    $display("highest = %0d, lowest = %0d", top[0], low[0]);

    // sort() reorders the queue ascending, in place
    scores.sort();
    $display("after sort: lowest index 0 = %0d, highest index $ = %0d",
             scores[0], scores[$]);

    // find() with a condition returns every matching element
    passed = scores.find(s) with (s >= 70);
    $display("scores >= 70 -> %0d of them", passed.size());

    // find_index() returns the positions of matches
    idx = scores.find_index(s) with (s == 90);
    $display("value 90 appears at %0d position(s)", idx.size());
    $finish;
  end
endmodule
