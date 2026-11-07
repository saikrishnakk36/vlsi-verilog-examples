// Fixed-priority arbiter returning a one-hot grant, a binary index and a valid flag
module priority_arbiter_idx #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0]         req,
    output reg  [WIDTH-1:0]         grant,
    output reg  [$clog2(WIDTH)-1:0] grant_idx,
    output reg                      valid
);
    integer i;
    reg found;
    always @(*) begin
        grant     = {WIDTH{1'b0}};
        grant_idx = {$clog2(WIDTH){1'b0}};
        valid     = 1'b0;
        found     = 1'b0;
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (!found && req[i]) begin
                grant[i]  = 1'b1;
                grant_idx = i[$clog2(WIDTH)-1:0];
                valid     = 1'b1;
                found     = 1'b1;
            end
        end
    end
endmodule

module tb_priority_arbiter_idx;
    localparam WIDTH = 4;
    reg  [WIDTH-1:0]         req;
    wire [WIDTH-1:0]         grant;
    wire [$clog2(WIDTH)-1:0] grant_idx;
    wire                     valid;

    priority_arbiter_idx #(.WIDTH(WIDTH)) dut (
        .req(req), .grant(grant), .grant_idx(grant_idx), .valid(valid)
    );

    initial begin
        $monitor("t=%0t req=%b grant=%b idx=%0d valid=%b",
                 $time, req, grant, grant_idx, valid);
        req = 4'b0000; #5;
        req = 4'b1010; #5;
        req = 4'b1100; #5;
        req = 4'b1000; #5;
        req = 4'b0110; #5;
        $finish;
    end
endmodule
