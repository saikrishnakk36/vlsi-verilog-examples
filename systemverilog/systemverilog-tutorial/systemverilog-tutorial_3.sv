// A transaction described as a class, with a randomisation constraint
class Packet;
  rand bit [7:0] addr;
  rand bit [3:0] len;
  constraint c_len { len inside {[1:8]}; }   // keep length in a legal range
endclass

module tb;
  initial begin
    Packet    p;
    bit [3:0] lengths[$];            // a dynamic queue of 4-bit values
    int       ok;

    p = new();
    for (int i = 0; i < 4; i++) begin
      ok = p.randomize();
      if (ok == 0) $fatal(1, "randomize() failed");
      $display("packet %0d: addr=%3d len=%0d", i, p.addr, p.len);
      lengths.push_back(p.len);
    end

    $display("collected %0d lengths, first=%0d last=%0d",
             lengths.size(), lengths[0], lengths[$]);
    $finish;
  end
endmodule
