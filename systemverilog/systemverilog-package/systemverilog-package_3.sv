package pkt_pkg;
  parameter int ADDR_W = 4;
  parameter int DATA_W = 8;

  // a reusable packed struct shared by many modules
  typedef struct packed {
    logic [ADDR_W-1:0] addr;
    logic [DATA_W-1:0] data;
    logic              valid;
  } packet_t;

  function automatic packet_t make_packet(logic [ADDR_W-1:0] a,
                                           logic [DATA_W-1:0] d);
    packet_t p;
    p.addr  = a;
    p.data  = d;
    p.valid = 1'b1;
    return p;
  endfunction
endpackage

module tb;
  import pkt_pkg::*;

  packet_t pkt;

  initial begin
    pkt = make_packet(4'hA, 8'h3C);
    $display("addr=0x%0h data=0x%0h valid=%b", pkt.addr, pkt.data, pkt.valid);
    $display("raw packed bits = %b", pkt);   // 4 + 8 + 1 = 13 bits
    $finish;
  end
endmodule
