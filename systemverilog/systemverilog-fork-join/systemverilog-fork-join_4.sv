module tb;
  initial begin
    // Case 1: the job (20ns) beats the 50ns timeout.
    $display("[%0t] case 1: 20ns job under a 50ns timeout", $time);
    fork
      begin : WORK_1
        #20 $display("[%0t]   job finished", $time);
      end
      begin : TIMEOUT_1
        #50 $display("[%0t]   TIMEOUT fired", $time);
      end
    join_any
    disable fork;   // kill whichever branch lost the race

    // Case 2: the job (80ns) is too slow; the 50ns timeout wins.
    $display("[%0t] case 2: 80ns job under a 50ns timeout", $time);
    fork
      begin : WORK_2
        #80 $display("[%0t]   job finished", $time);
      end
      begin : TIMEOUT_2
        #50 $display("[%0t]   TIMEOUT fired", $time);
      end
    join_any
    disable fork;

    $display("[%0t] done", $time);
    $finish;
  end
endmodule
