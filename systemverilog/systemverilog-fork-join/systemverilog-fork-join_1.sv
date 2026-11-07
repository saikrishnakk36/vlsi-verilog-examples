module tb;
  initial begin
    $display("[%0t] main: entering fork-join", $time);
    fork
      begin : P1
        #10 $display("[%0t] P1 done (10ns job)", $time);
      end
      begin : P2
        #30 $display("[%0t] P2 done (30ns job)", $time);
      end
      begin : P3
        #20 $display("[%0t] P3 done (20ns job)", $time);
      end
    join
    $display("[%0t] main: all three finished, continuing", $time);
    #5 $display("[%0t] main: done", $time);
    $finish;
  end
endmodule
