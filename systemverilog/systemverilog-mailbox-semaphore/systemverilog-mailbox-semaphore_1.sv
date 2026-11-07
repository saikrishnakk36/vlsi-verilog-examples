module tb;
  mailbox #(int) mbx = new();
  task automatic producer();
    for (int i = 1; i <= 4; i++) begin
      #5;
      mbx.put(i * 10);
      $display("[%0t] producer sent %0d", $time, i*10);
    end
  endtask
  task automatic consumer();
    int item;
    repeat (4) begin
      mbx.get(item);
      $display("[%0t] consumer got  %0d", $time, item);
    end
  endtask
  initial begin
    fork producer(); consumer(); join
    $display("done, msgs left=%0d", mbx.num());
    $finish;
  end
endmodule
