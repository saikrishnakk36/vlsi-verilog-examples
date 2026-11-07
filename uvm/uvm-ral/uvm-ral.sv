// Plain-SystemVerilog illustration of the RAL idea: a mirrored value.
// No UVM library required. The top module is named tb.
module tb;
  logic [7:0] dut_reg;   // the real register living inside the DUT
  logic [7:0] mirror;    // what RAL predicts the register currently holds
  logic [7:0] rdata;

  // A bus write: the hardware updates AND the "predictor" updates the mirror.
  task automatic bus_write(input [7:0] data);
    dut_reg = data;
    mirror  = data;
    $display("WRITE data=0x%02h  mirror=0x%02h", data, mirror);
  endtask

  // A bus read returns the actual hardware value.
  task automatic bus_read(output [7:0] data);
    data = dut_reg;
    $display("READ  data=0x%02h  mirror=0x%02h", data, mirror);
  endtask

  initial begin
    dut_reg = 8'h00;
    mirror  = 8'h00;

    // reg.write(0xA5): drive the bus; the predictor tracks the value.
    bus_write(8'hA5);

    // reg.read(): compare the read-back against the predicted mirror.
    bus_read(rdata);
    if (rdata === mirror) $display("PASS: read-back matches mirror (0x%02h)", rdata);
    else                  $display("FAIL: 0x%02h does not match 0x%02h", rdata, mirror);

    // Inject an RTL bug: the register changes with no bus transaction,
    // so the mirror is never updated and the prediction diverges.
    dut_reg = 8'h3C;
    bus_read(rdata);
    if (rdata === mirror) $display("PASS: still in sync");
    else                  $display("MISMATCH caught: actual 0x%02h vs predicted 0x%02h", rdata, mirror);

    $finish;
  end
endmodule

