module tb;
  class Packet;
    rand  bit [7:0] length;
    randc bit [1:0] priority_id;
    rand  bit [3:0] src_port;

    constraint c_len  { length inside {[8:64]}; }
    constraint c_port { src_port inside {[1:14]}; }
  endclass

  Packet p;

  initial begin
    p = new();
    for (int i = 0; i < 4; i++) begin
      if (p.randomize() == 0)
        $fatal(1, "randomize failed");
      $display("run=%0d length=%0d priority_id=%0d src_port=%0d",
               i, p.length, p.priority_id, p.src_port);
    end
    $finish;
  end
endmodule
