module tb;
  typedef struct packed {
    logic [7:0]  opcode;
    logic [7:0]  addr;
    logic [15:0] data;
  } instr_t;
  initial begin
    logic [31:0] word;
    instr_t ins;
    word = 32'hA5_10_BEEF;
    ins  = instr_t'(word);   // bit-stream cast: vector -> packed struct
    $display("opcode = %02h", ins.opcode);
    $display("addr   = %02h", ins.addr);
    $display("data   = %04h", ins.data);
    ins.opcode = 8'h01;
    word = 32'(ins);         // reverse: struct -> 32-bit vector
    $display("repacked = %08h", word);
    $finish;
  end
endmodule
