// txn.sv - weighted distribution with dist
module tb;
  typedef enum {READ, WRITE, IDLE} op_e;

  class Txn;
    rand op_e      op;
    rand bit [7:0] len;
    // READ 60%, WRITE 30%, IDLE 10%
    constraint c_op  { op dist {READ := 6, WRITE := 3, IDLE := 1}; }
    // small lengths very common, the wide band rare
    constraint c_len { len dist {[1:4] :/ 80, [5:255] :/ 20}; }
  endclass

  Txn t;
  int ok;

  initial begin
    t = new();
    ok = t.randomize();
    $display("op=%s len=%0d", t.op.name(), t.len);
  end
endmodule
