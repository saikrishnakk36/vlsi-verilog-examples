module tb;
  byte          sb;   // signed 8-bit, range -128..127
  byte unsigned ub;   // unsigned 8-bit, range 0..255
  int           i;    // signed 32-bit
  longint       l;    // signed 64-bit

  initial begin
    sb = 8'd200;      // 200 does not fit in a signed byte -> wraps
    ub = 8'd200;      // fits in an unsigned byte
    $display("byte          200 -> %0d", sb);
    $display("byte unsigned 200 -> %0d", ub);

    i = 32'h8000_0000;             // MSB set -> most negative int
    $display("int  0x80000000   -> %0d", i);

    l = 64'sd9223372036854775807;  // largest signed longint
    $display("longint max       -> %0d", l);
    l = l + 1;                     // signed overflow wraps to the minimum
    $display("longint max + 1   -> %0d", l);

    $finish;
  end
endmodule
