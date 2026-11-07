module tb;
  int hits [4];
  int stimulus [8];
  int covered;
  initial begin
    stimulus = '{0, 1, 2, 1, 3, 0, 2, 1};
    foreach (stimulus[i]) hits[stimulus[i]]++;
    covered = 0;
    foreach (hits[i]) begin
      $display("bin opcode==%0d : %0d hits", i, hits[i]);
      if (hits[i] > 0) covered++;
    end
    $display("Functional coverage = %0d/4 bins hit = %0d%%", covered, covered*100/4);
    if (covered == 4) $display("Coverage goal reached");
    else $display("Coverage goal NOT reached");
    $finish;
  end
endmodule
