module tb;
  logic clk = 0;
  logic [7:0] data;
  logic       valid;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    default input #1step output #2;
    output data, valid;
  endclocking

  initial begin
    data  = '0;
    valid = 1'b0;
    ##1;
    cb.data  <= 8'hA5;
    cb.valid <= 1'b1;
    ##1;
    $display("after 1st drive: t=%0t data=%02h valid=%b", $time, data, valid);
    ##2;
    $display("done at t=%0t", $time);
    $finish;
  end
endmodule
