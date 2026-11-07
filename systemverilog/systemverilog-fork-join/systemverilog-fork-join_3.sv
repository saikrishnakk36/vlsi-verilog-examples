module tb;
  initial begin
    $display("[%0t] spawning 3 background workers with join_none", $time);
    fork
      #10 $display("[%0t] worker 1 finished (10ns)", $time);
    join_none
    fork
      #30 $display("[%0t] worker 2 finished (30ns)", $time);
    join_none
    fork
      #20 $display("[%0t] worker 3 finished (20ns)", $time);
    join_none
    $display("[%0t] all workers launched; main keeps running immediately", $time);
    #5 $display("[%0t] main did a quick 5ns chore while workers run", $time);
    wait fork;
    $display("[%0t] wait fork returned: every worker is done", $time);
    $finish;
  end
endmodule
