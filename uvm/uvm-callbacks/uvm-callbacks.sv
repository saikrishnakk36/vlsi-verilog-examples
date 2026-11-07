// A fixed, reusable component. We never edit its source to inject errors.
module driver(input clk, input [7:0] item, output reg [7:0] bus);
  always @(posedge clk) begin
    bus <= item;
    $display("[%0t] driver drove bus = 0x%02h", $time, item);
  end
endmodule

// The "hook". By default it is a pass-through, so data is clean.
// External code flips err_mask to shape the item, without touching driver.
module shaper(input [7:0] original, output [7:0] shaped);
  reg [7:0] err_mask;
  initial err_mask = 8'h00;
  assign shaped = original ^ err_mask;
endmodule

// Top-level testbench (listed last).
module tb;
  reg        clk = 1'b0;
  reg  [7:0] item;
  wire [7:0] shaped, bus;

  shaper u_shaper(.original(item), .shaped(shaped));
  driver u_driver(.clk(clk), .item(shaped), .bus(bus));

  always #5 clk = ~clk;

  initial begin
    item = 8'hA5;
    @(posedge clk); #1;
    $display("clean run   : item=0x%02h bus=0x%02h (callback inactive)", item, bus);

    // "Register" an error-injection callback at the hook -- driver is untouched.
    u_shaper.err_mask = 8'hFF;
    @(posedge clk); #1;
    $display("all-bit flip: item=0x%02h bus=0x%02h", item, bus);

    u_shaper.err_mask = 8'h01;
    @(posedge clk); #1;
    $display("1-bit error : item=0x%02h bus=0x%02h", item, bus);

    $display("done");
    $finish;
  end
endmodule
