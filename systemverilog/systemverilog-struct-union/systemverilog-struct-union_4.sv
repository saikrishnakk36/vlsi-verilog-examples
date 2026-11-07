package bus_pkg;
  typedef struct packed {
    logic        valid;
    logic [7:0]  addr;
    logic [15:0] data;
  } req_t;
endpackage

module decoder (
  input  bus_pkg::req_t req,
  output logic          hit
);
  assign hit = req.valid && (req.addr == 8'h40);
endmodule

module tb;
  import bus_pkg::*;
  req_t req;
  logic hit;

  decoder dut (.req(req), .hit(hit));

  initial begin
    req.valid = 1'b1;
    req.addr  = 8'h40;
    req.data  = 16'h1234;
    #1;
    $display("addr=%h hit=%b", req.addr, hit);

    req.addr = 8'h7f;
    #1;
    $display("addr=%h hit=%b", req.addr, hit);
    $finish;
  end
endmodule

