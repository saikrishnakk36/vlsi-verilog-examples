module tb;
  // STATIC function: one shared copy of count survives every call
  function int static_counter();
    static int count = 0;   // initialised once, at time 0
    count++;
    return count;
  endfunction

  // AUTOMATIC function: fresh count allocated on each call
  function automatic int auto_counter();
    int count = 0;          // re-created and re-initialised every call
    count++;
    return count;
  endfunction

  initial begin
    int s1, s2, s3;
    int a1, a2, a3;
    s1 = static_counter();
    s2 = static_counter();
    s3 = static_counter();
    a1 = auto_counter();
    a2 = auto_counter();
    a3 = auto_counter();
    $display("static_counter : %0d %0d %0d", s1, s2, s3);
    $display("auto_counter   : %0d %0d %0d", a1, a2, a3);
    $finish;
  end
endmodule
