// addr.sv - constraint_mode and rand_mode control knobs
module tb;
  class Addr;
    rand bit [7:0] base;
    rand bit [7:0] offset;
    constraint c_low { base inside {[0:15]}; }  // keep base small
  endclass

  Addr a;
  int  ok;

  initial begin
    a = new();

    // 1) default: c_low active, both fields random
    ok = a.randomize();
    $display("default      : base=%0d offset=%0d", a.base, a.offset);

    // 2) switch off the c_low constraint -> base may use full range
    a.c_low.constraint_mode(0);
    ok = a.randomize();
    $display("c_low off    : base=%0d offset=%0d", a.base, a.offset);

    // 3) freeze offset with rand_mode(0): keep value, randomize the rest
    a.offset.rand_mode(0);
    a.base = 0;
    ok = a.randomize();
    $display("offset frozen: base=%0d offset=%0d (unchanged)", a.base, a.offset);

    // 4) re-enable both
    a.c_low.constraint_mode(1);
    a.offset.rand_mode(1);
    ok = a.randomize();
    $display("all restored : base=%0d offset=%0d", a.base, a.offset);
    if (ok == 0) $display("randomize failed");
    $finish;
  end
endmodule
