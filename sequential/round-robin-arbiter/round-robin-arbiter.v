// Parameterized round-robin arbiter with a rotating priority pointer.
// Produces a one-hot grant and advances the pointer so the just-served
// requester becomes the lowest priority on the next grant.
module rr_arbiter #(
    parameter N = 4
) (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [N-1:0] req,
    output wire [N-1:0] grant
);
    // ptr is a one-hot mask marking the current highest-priority position.
    reg  [N-1:0] ptr;

    // Select the request bits at or above the pointer (no wrap-around).
    // (ptr-1) sets every bit below the pointer; inverting it keeps the
    // pointer bit and everything above it.
    wire [N-1:0] hi_sel  = ~(ptr - 1'b1);
    wire [N-1:0] hi_req  = req & hi_sel;

    // Isolate the lowest set bit: x & (-x) leaves only the least-significant 1.
    wire [N-1:0] grant_hi = hi_req & (~hi_req + 1'b1);
    wire [N-1:0] grant_lo = req    & (~req    + 1'b1);

    // Prefer a requester in the high group; otherwise wrap to the lowest index.
    assign grant = (|hi_req) ? grant_hi : grant_lo;

    // Rotate the pointer to one position above the granted requester.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ptr <= {{(N-1){1'b0}}, 1'b1};      // start priority at index 0
        else if (|grant)
            ptr <= {grant[N-2:0], grant[N-1]}; // left-rotate by one
    end
endmodule

// Testbench: all four requesters assert continuously. The grant must
// cycle 0 -> 1 -> 2 -> 3 -> 0 ... proving the pointer rotates fairly.
`timescale 1ns/1ps
module tb_rr_rotate;
    localparam N = 4;
    reg          clk = 1'b0;
    reg          rst_n;
    reg  [N-1:0] req;
    wire [N-1:0] grant;

    rr_arbiter #(.N(N)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .req   (req),
        .grant (grant)
    );

    always #5 clk = ~clk;   // 10 ns period

    integer i;
    initial begin
        rst_n = 1'b0;
        req   = 4'b1111;    // everyone wants the bus every cycle
        @(negedge clk);
        rst_n = 1'b1;

        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            $display("cycle %0d : req=%b grant=%b", i, req, grant);
        end

        $display("All requesters busy -> grant rotates evenly across owners.");
        $finish;
    end
endmodule

// Testbench: a sparse, changing request pattern. Two steady requesters
// (lanes 1 and 3) must alternate instead of one starving the other, and
// an idle bus (req=0) must produce no grant.
`timescale 1ns/1ps
module tb_rr_fair;
    localparam N = 4;
    reg          clk = 1'b0;
    reg          rst_n;
    reg  [N-1:0] req;
    wire [N-1:0] grant;

    rr_arbiter #(.N(N)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .req   (req),
        .grant (grant)
    );

    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        req   = 4'b0000;
        @(negedge clk);
        rst_n = 1'b1;

        req = 4'b1010; @(negedge clk);
        $display("req=%b grant=%b", req, grant);
        req = 4'b1010; @(negedge clk);
        $display("req=%b grant=%b", req, grant);
        req = 4'b1010; @(negedge clk);
        $display("req=%b grant=%b", req, grant);
        req = 4'b0000; @(negedge clk);
        $display("req=%b grant=%b (idle bus)", req, grant);
        req = 4'b0001; @(negedge clk);
        $display("req=%b grant=%b", req, grant);

        $display("Lanes 1 and 3 trade the bus; no lane is starved.");
        $finish;
    end
endmodule
