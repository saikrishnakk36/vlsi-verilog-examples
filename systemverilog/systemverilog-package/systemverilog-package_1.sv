package comms_pkg;
  parameter int BUS_WIDTH = 8;

  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;

  function automatic logic parity(input logic [BUS_WIDTH-1:0] d);
    return ^d;  // XOR reduction = parity bit
  endfunction
endpackage

module tb;
  import comms_pkg::*;   // wildcard import: types, params, functions, enum labels

  logic [BUS_WIDTH-1:0] frame;
  state_t st;

  initial begin
    frame = 8'b1011_0010;
    st    = START;
    $display("BUS_WIDTH    = %0d", BUS_WIDTH);
    $display("current state = %s", st.name());
    $display("parity(0x%02h) = %b", frame, parity(frame));
    $finish;
  end
endmodule
