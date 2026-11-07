module tb;
  typedef struct packed {
    logic [7:0] high;
    logic [7:0] low;
  } bytes_t;

  typedef union packed {
    logic [15:0] word;
    bytes_t      b;
  } reg16_t;

  reg16_t r;

  initial begin
    r.word = 16'hDEAD;
    $display("word=%h  high=%h  low=%h", r.word, r.b.high, r.b.low);

    r.b.low = 8'hBE;
    $display("after low=BE, word=%h", r.word);
    $finish;
  end
endmodule

