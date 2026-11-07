module tb;
  semaphore bus = new(2);
  task automatic drive(string name, int cost);
    $display("[%0t] %s requests %0d key(s)", $time, name, cost);
    bus.get(cost);
    $display("[%0t] %s ACQUIRED %0d key(s)", $time, name, cost);
    #5;
    bus.put(cost);
    $display("[%0t] %s released %0d key(s)", $time, name, cost);
  endtask
  initial begin
    fork
      begin #1; drive("rtl_core", 1); end
      begin #2; drive("dma_eng ", 1); end
      begin #3; drive("burst_io", 2); end
    join
    $display("[%0t] bus idle, keys restored", $time);
    $finish;
  end
endmodule
