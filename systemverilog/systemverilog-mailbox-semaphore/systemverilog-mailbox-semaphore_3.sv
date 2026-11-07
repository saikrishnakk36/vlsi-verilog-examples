class packet;
  int addr;
  int data;
  function new(int a, int d);
    addr = a;
    data = d;
  endfunction
endclass

module tb;
  mailbox #(packet) mbx = new();

  task automatic monitor();
    packet p;
    #1;
    mbx.peek(p);
    $display("[%0t] monitor PEEK addr=%0h  depth=%0d", $time, p.addr, mbx.num());
    mbx.get(p);
    $display("[%0t] monitor GET  addr=%0h data=%0h  depth=%0d",
             $time, p.addr, p.data, mbx.num());
  endtask

  initial begin
    packet q;
    q = new('h40, 'hBEEF);
    mbx.put(q);
    $display("[%0t] driver PUT  addr=%0h", $time, q.addr);
    monitor();
    $finish;
  end
endmodule
