interface bus_if(input logic clk);
  logic       valid;
  logic [7:0] data;

  modport dut (input clk, input valid, input data);

  task automatic send(input logic [7:0] d);
    @(negedge clk);
    valid = 1'b1;
    data  = d;
    @(posedge clk);
    @(negedge clk);
    valid = 1'b0;
  endtask
endinterface

module sink(bus_if.dut b);
  always_ff @(posedge b.clk)
    if (b.valid)
      $display("received data = %0d", b.data);
endmodule

module tb;
  logic clk = 0;
  always #5 clk = ~clk;

  bus_if b(clk);
  sink dut(b.dut);

  initial begin
    b.valid = 0;
    b.data  = 0;
    b.send(8'd42);
    b.send(8'd99);
    repeat (2) @(posedge clk);
    $display("done");
    $finish;
  end
endmodule
