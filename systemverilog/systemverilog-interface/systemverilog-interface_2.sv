interface counter_if(input logic clk);
  logic       rst;
  logic       en;
  logic [3:0] count;

  modport dut (input clk, input rst, input en, output count);
  modport tb  (input clk, output rst, output en, input count);
endinterface

module counter(counter_if.dut cif);
  always_ff @(posedge cif.clk) begin
    if (cif.rst)
      cif.count <= 4'd0;
    else if (cif.en)
      cif.count <= cif.count + 4'd1;
  end
endmodule

module tb;
  logic clk = 0;
  always #5 clk = ~clk;

  counter_if cif(clk);
  counter dut(cif.dut);

  initial begin
    cif.rst = 1;
    cif.en  = 0;
    @(posedge clk);
    cif.rst = 0;
    cif.en  = 1;
    repeat (5) @(posedge clk);
    $display("count after 5 enabled cycles = %0d", cif.count);
    cif.en = 0;
    @(posedge clk);
    $display("count with en=0 = %0d", cif.count);
    $finish;
  end
endmodule
