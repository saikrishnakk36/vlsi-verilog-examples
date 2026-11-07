class Frame;
  rand bit [7:0] id;
  rand bit [7:0] data;
endclass

module tb;
  Frame f = new();
  int ok;
  initial begin
    // Randomize both fields, tying data to id for this call only.
    ok = f.randomize() with { id inside {[1:4]}; data == id * 16; };
    $display("call 1 : id=%0d data=%0d", f.id, f.data);

    // Freeze id: rand_mode(0) makes the solver treat it as a constant.
    f.id.rand_mode(0);
    ok = f.randomize() with { data inside {[200:255]}; };
    $display("call 2 : id=%0d data=%0d  (id frozen)", f.id, f.data);

    // Thaw id again and randomize both fields together.
    f.id.rand_mode(1);
    ok = f.randomize() with { id > 100; data < 16; };
    $display("call 3 : id=%0d data=%0d  (id active again)", f.id, f.data);
    $finish;
  end
endmodule
