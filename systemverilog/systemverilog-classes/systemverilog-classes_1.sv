module tb;
  class Packet;
    int unsigned addr;
    byte payload;
    static int count = 0;

    function new(int unsigned addr = 0, byte payload = 0);
      this.addr    = addr;
      this.payload = payload;
      count++;
    endfunction

    function void print(string tag);
      $display("[%s] addr=0x%02h payload=%0d (objects so far=%0d)",
               tag, addr, payload, count);
    endfunction
  endclass

  initial begin
    Packet p1;
    Packet p2;
    p1 = new(8'hA0, 42);
    p2 = new();
    p1.print("p1");
    p2.print("p2-default");
    p2.addr    = 8'hFF;
    p2.payload = 7;
    p2.print("p2-updated");
    $finish;
  end
endmodule
