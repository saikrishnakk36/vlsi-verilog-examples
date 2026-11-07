module tb;
  string line;
  int    id;
  logic [7:0] addr;

  initial begin
    id   = 7;
    addr = 8'hA5;

    // $sformatf returns a formatted string instead of printing it
    line = $sformatf("packet id=%0d addr=0x%02h", id, addr);
    $display("line = %s", line);
    $display("len  = %0d", line.len());

    // Build messages incrementally for logging or UVM-style reports
    for (int i = 0; i < 3; i++) begin
      string tag;
      tag = $sformatf("[ch%0d]", i);
      $display("%s processed at %0t", tag, $time);
    end

    // Width, zero-pad, and radix controls work just like $display
    $display("%s", $sformatf("bin=%08b dec=%4d hex=%h", addr, id, addr));
    $finish;
  end
endmodule
