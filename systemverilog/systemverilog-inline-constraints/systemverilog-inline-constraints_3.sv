class Addr;
  rand bit [7:0] addr;
  constraint c_align { addr % 4 == 0; }
  constraint c_low   { addr < 16; }
endclass

module tb;
  Addr a = new();
  int ok;
  initial begin
    ok = a.randomize();
    $display("both on : addr=%0d  (multiple of 4 and < 16)", a.addr);

    a.c_low.constraint_mode(0);        // switch off only the "addr < 16" rule
    ok = a.randomize();
    $display("low off : addr=%0d  (still a multiple of 4)", a.addr);

    a.constraint_mode(0);              // switch off every constraint in the object
    ok = a.randomize() with { addr == 77; };
    $display("all off : addr=%0d  (only the inline rule is left)", a.addr);
    $finish;
  end
endmodule
