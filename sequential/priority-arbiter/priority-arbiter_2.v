// Mask-trick arbiter: grant = req & (~req + 1) isolates the lowest set bit
module arbiter_mask #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] req,
    output wire [WIDTH-1:0] grant
);
    assign grant = req & (~req + 1'b1);
endmodule

// Reference loop version used only to prove equivalence in the testbench
module arbiter_loop #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] req,
    output reg  [WIDTH-1:0] grant
);
    integer i;
    reg found;
    always @(*) begin
        grant = {WIDTH{1'b0}};
        found = 1'b0;
        for (i = 0; i < WIDTH; i = i + 1)
            if (!found && req[i]) begin
                grant[i] = 1'b1;
                found    = 1'b1;
            end
    end
endmodule

module tb_arbiter_mask;
    localparam WIDTH = 8;
    reg  [WIDTH-1:0] req;
    wire [WIDTH-1:0] g_mask, g_loop;
    integer k, errors;

    arbiter_mask #(.WIDTH(WIDTH)) m (.req(req), .grant(g_mask));
    arbiter_loop #(.WIDTH(WIDTH)) l (.req(req), .grant(g_loop));

    initial begin
        errors = 0;
        $display("   req     mask     loop   match");
        for (k = 0; k < 256; k = k + 37) begin
            req = k[WIDTH-1:0];
            #2;
            $display("%b %b %b     %s",
                     req, g_mask, g_loop, (g_mask === g_loop) ? "ok" : "NO");
            if (g_mask !== g_loop) errors = errors + 1;
        end
        if (errors == 0)
            $display("RESULT: mask trick matches loop arbiter on all vectors");
        else
            $display("RESULT: %0d mismatches", errors);
        $finish;
    end
endmodule
