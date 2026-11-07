// Fixed-priority arbiter: bit 0 = highest priority, parameterized width
module priority_arbiter #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] req,
    output reg  [WIDTH-1:0] grant
);
    integer i;
    reg found;
    always @(*) begin
        grant = {WIDTH{1'b0}};
        found = 1'b0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (!found && req[i]) begin
                grant[i] = 1'b1;
                found    = 1'b1;
            end
        end
    end
endmodule

module tb_priority_arbiter;
    localparam WIDTH = 4;
    reg  [WIDTH-1:0] req;
    wire [WIDTH-1:0] grant;

    priority_arbiter #(.WIDTH(WIDTH)) dut (.req(req), .grant(grant));

    integer k;
    initial begin
        $display("  req  -> grant  (bit0 = highest priority)");
        for (k = 0; k < 16; k = k + 1) begin
            req = k[WIDTH-1:0];
            #5;
            $display("  %b ->  %b", req, grant);
        end
        $finish;
    end
endmodule
