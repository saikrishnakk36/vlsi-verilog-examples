module tb;
  typedef enum logic [3:0] {
    OP_NOP   = 4'h0,
    OP_ADD   = 4'h1,
    OP_SUB   = 4'h2,
    OP_LOAD  = 4'h8,
    OP_STORE = 4'h9
  } opcode_t;

  opcode_t op;
  logic [3:0] raw;
  opcode_t decoded;
  string    nm;

  initial begin
    op = OP_LOAD;
    $display("OP_LOAD encodes to 0x%0h", op);

    raw = 4'h2;
    decoded = opcode_t'(raw);
    $display("bus 0x%0h decodes to %s", raw, decoded.name());

    raw = 4'h5;
    decoded = opcode_t'(raw);
    nm = decoded.name();
    $display("bus 0x%0h decodes to '%s' (len=%0d)", raw, nm, nm.len());
    $finish;
  end
endmodule
