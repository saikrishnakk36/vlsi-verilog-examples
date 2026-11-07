module tb;
  class Frame;
    rand bit [7:0] payload;
    rand bit       is_jumbo;

    // Implication: a jumbo frame forces a large payload.
    // When is_jumbo is 0, payload is left free.
    constraint c_jumbo { is_jumbo -> payload > 200; }
    constraint c_pl    { payload > 0; }
  endclass

  Frame f;
  int jumbo_cnt, normal_cnt;

  initial begin
    f = new();
    for (int i = 0; i < 12; i++) begin
      if (f.randomize() == 0) $fatal(1, "randomize failed");
      if (f.is_jumbo) jumbo_cnt++; else normal_cnt++;
      // Prove the implication on every single draw
      if (f.is_jumbo && !(f.payload > 200))
        $fatal(1, "implication broken: jumbo with payload %0d", f.payload);
      $display("draw=%0d is_jumbo=%0d payload=%0d", i, f.is_jumbo, f.payload);
    end
    $display("jumbo=%0d normal=%0d implication held every time",
             jumbo_cnt, normal_cnt);
    $finish;
  end
endmodule
