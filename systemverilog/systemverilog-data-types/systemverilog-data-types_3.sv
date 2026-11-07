module tb;
  // typedef names a reusable type. A packed struct lays its fields out
  // as one contiguous vector, MSB-first in declaration order.
  typedef struct packed {
    logic [7:0]  opcode;
    logic [7:0]  addr;
    logic [15:0] data;
  } instr_t;

  // A packed union views the same 32 bits two ways at once.
  typedef union packed {
    instr_t      f;    // as named fields
    logic [31:0] raw;  // as one flat vector
  } word_t;

  word_t w;

  initial begin
    // Write through the field view, read back through the flat view.
    w.f.opcode = 8'hA5;
    w.f.addr   = 8'h10;
    w.f.data   = 16'hBEEF;
    $display("assembled raw word = 0x%08h", w.raw);

    // Write the flat view, read back as decoded fields.
    w.raw = 32'h12_34_5678;
    $display("decoded: opcode=0x%02h addr=0x%02h data=0x%04h",
             w.f.opcode, w.f.addr, w.f.data);

    // The union lets us slice the same storage as a plain vector.
    $display("top byte via slice = 0x%02h", w.raw[31:24]);

    $finish;
  end
endmodule
