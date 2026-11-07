module tb;
  logic [3:0] four_state;   // 4-state: starts X
  bit   [3:0] two_state;    // 2-state: starts 0

  initial begin
    $display("logic (uninitialised) = %b", four_state);
    $display("bit   (uninitialised) = %b", two_state);

    four_state = 4'b10xz;
    $display("logic holds X/Z        = %b", four_state);

    two_state = four_state;   // X and Z collapse to 0 when copied into 2-state
    $display("bit after copy         = %b", two_state);

    if (four_state === 4'b10xz)
      $display("=== match: X/Z compared exactly");

    $finish;
  end
endmodule
