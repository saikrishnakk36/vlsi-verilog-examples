class Packet;
  rand bit [7:0] len;
  rand bit [1:0] prio;
endclass

module tb;
  Packet p = new();
  int ok;
  initial begin
    for (int i = 0; i < 4; i++) begin
      ok = p.randomize() with { len inside {[8:16]}; prio == 2'b11; };
      if (ok == 0)
        $display("trial %0d: randomize failed", i);
      else
        $display("trial %0d: len=%0d prio=%0d", i, p.len, p.prio);
    end
    $finish;
  end
endmodule
