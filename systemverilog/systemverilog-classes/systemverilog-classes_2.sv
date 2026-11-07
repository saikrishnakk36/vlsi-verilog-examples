module tb;
  class Transaction;
    int unsigned addr;
    int unsigned data;

    function new(int unsigned addr, int unsigned data);
      this.addr = addr;
      this.data = data;
    endfunction

    function void show();
      $display("  addr=0x%0h data=0x%0h", addr, data);
    endfunction
  endclass

  class WriteTxn extends Transaction;
    bit [3:0] strobe;

    function new(int unsigned addr, int unsigned data, bit [3:0] strobe);
      super.new(addr, data);
      this.strobe = strobe;
    endfunction

    function void show();
      $display("WriteTxn:");
      super.show();
      $display("  strobe=0b%04b", strobe);
    endfunction
  endclass

  initial begin
    Transaction t;
    WriteTxn    w;
    t = new(32'h1000, 32'hDEAD);
    $display("Transaction:");
    t.show();
    w = new(32'h2000, 32'hBEEF, 4'b1010);
    w.show();
    $finish;
  end
endmodule
