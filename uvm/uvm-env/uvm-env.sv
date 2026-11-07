// tb.sv -- the UVM env "build then connect" pattern, plain SystemVerilog, no UVM
module tb;

  // Plays the role of uvm_analysis_imp: receives transactions via write()
  class scoreboard;
    int received;
    function void write(int txn);
      received++;
      $display("[SCB] got txn=%0d (total=%0d)", txn, received);
    endfunction
  endclass

  // Holds an analysis-port-like handle to a subscriber
  class monitor;
    scoreboard ap;
    function void observe(int txn);
      if (ap != null) ap.write(txn);
    endfunction
  endclass

  // An agent groups a monitor, like a uvm_agent inside the env
  class agent;
    monitor mon;
    function void build();     // mirrors build_phase
      mon = new();
    endfunction
  endclass

  // The env: build all children first, THEN connect them
  class env;
    agent      agt;
    scoreboard scb;
    function void build();     // top-down construction
      agt = new();
      scb = new();
      agt.build();
    endfunction
    function void connect();   // wiring, after everything exists
      agt.mon.ap = scb;        // monitor.port.connect(scoreboard)
    endfunction
  endclass

  env e;
  initial begin
    e = new();
    e.build();                 // construct ...
    e.connect();               // ... then connect, like UVM phases
    e.agt.mon.observe(10);
    e.agt.mon.observe(20);
    e.agt.mon.observe(30);
    $display("[TB] scoreboard saw %0d transactions", e.scb.received);
    $finish;
  end
endmodule
