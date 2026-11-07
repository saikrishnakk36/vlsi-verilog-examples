module tb;
  mailbox #(int) mbx = new(2);
  task automatic producer();
    for (int i = 1; i <= 5; i++) begin
      mbx.put(i);
      $display("[%0t] put %0d (occupancy now %0d/2)", $time, i, mbx.num());
      #1;
    end
  endtask
  task automatic consumer();
    int v;
    #3;
    repeat (5) begin
      mbx.get(v);
      $display("[%0t] got %0d", $time, v);
      #4;
    end
  endtask
  initial begin
    fork producer(); consumer(); join
    $display("all drained, left=%0d", mbx.num());
    $finish;
  end
endmodule
