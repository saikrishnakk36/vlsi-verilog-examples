module tb;
  bit clk = 0;
  int idx = 0;
  bit op_vec [6];
  bit sz_vec [6];
  int cross_hits [2][2];
  int combos;

  always #5 clk = ~clk;

  initial begin
    op_vec = '{0, 1, 0, 1, 1, 0};
    sz_vec = '{0, 0, 1, 1, 1, 0};
  end

  always @(posedge clk) begin
    if (idx < 6) begin
      cross_hits[op_vec[idx]][sz_vec[idx]] = cross_hits[op_vec[idx]][sz_vec[idx]] + 1;
      idx = idx + 1;
    end
    else begin
      combos = 0;
      for (int o = 0; o < 2; o++)
        for (int s = 0; s < 2; s++) begin
          $display("cross op=%0d x sz=%0d : %0d hits", o, s, cross_hits[o][s]);
          if (cross_hits[o][s] > 0) combos = combos + 1;
        end
      $display("Cross coverage = %0d/4 combinations = %0d%%", combos, combos*100/4);
      $finish;
    end
  end
endmodule
