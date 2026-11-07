module tb;
  // A task CAN consume time; a function cannot.
  // input args are copied in; the output arg is copied back when the task ends.
  task automatic gen_pulse(input int cycles, output bit done);
    done = 1'b0;
    repeat (cycles) #5;     // burn time: 'cycles' steps of 5 time units
    done = 1'b1;
    $display("[t=%0t] pulse done after %0d cycles", $time, cycles);
  endtask

  bit finished;

  initial begin
    finished = 1'b0;
    $display("[t=%0t] calling gen_pulse...", $time);
    gen_pulse(3, finished);                 // blocks here until the task returns
    $display("[t=%0t] finished = %0b", $time, finished);
    $finish;
  end
endmodule
