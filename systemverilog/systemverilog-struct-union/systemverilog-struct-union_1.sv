module tb;
  typedef struct packed {
    logic [7:0] src;
    logic [7:0] dst;
    logic [7:0] len;
  } header_t;

  header_t hdr;

  initial begin
    hdr.src = 8'h0a;
    hdr.dst = 8'h0b;
    hdr.len = 8'd64;
    $display("src=%h dst=%h len=%0d", hdr.src, hdr.dst, hdr.len);
    $display("whole header=%h  (%0d bits)", hdr, $bits(hdr));
    $finish;
  end
endmodule

