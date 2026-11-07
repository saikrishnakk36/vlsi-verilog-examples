module tb;
  initial begin
    $display("[%0t] firing two redundant requests, keeping the fastest", $time);
    fork
      begin : SERVER_A
        #40 $display("[%0t] SERVER_A replied", $time);
      end
      begin : SERVER_B
        #15 $display("[%0t] SERVER_B replied", $time);
      end
    join_any
    $display("[%0t] first reply is in, abandoning the slower one", $time);
    disable fork;
    $display("[%0t] cleaned up, moving on", $time);
    #50 $display("[%0t] end of test (SERVER_A never printed)", $time);
    $finish;
  end
endmodule
