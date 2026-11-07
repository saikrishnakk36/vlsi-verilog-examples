interface adder_if;
  logic [7:0] a;
  logic [7:0] b;
  logic [8:0] sum;
endinterface

module adder(adder_if aif);
  always_comb aif.sum = aif.a + aif.b;
endmodule

module tb;
  adder_if aif();
  adder dut(aif);

  initial begin
    aif.a = 8'd10;
    aif.b = 8'd20;
    #1;
    $display("a=%0d b=%0d sum=%0d", aif.a, aif.b, aif.sum);
    aif.a = 8'd200;
    aif.b = 8'd100;
    #1;
    $display("a=%0d b=%0d sum=%0d", aif.a, aif.b, aif.sum);
    $finish;
  end
endmodule
