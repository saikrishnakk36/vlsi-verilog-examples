// tlc_checked.v  -  Verilog-2005
// A compact traffic light FSM plus a SELF-CHECKING testbench that proves the
// most important safety property: the two roads must never be green together.

module tlc_checked #(
    parameter integer MAIN_GREEN  = 3,
    parameter integer MAIN_YELLOW = 1,
    parameter integer SIDE_GREEN  = 3,
    parameter integer SIDE_YELLOW = 1
) (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [1:0] main_light,
    output reg  [1:0] side_light
);
    localparam [1:0] RED = 2'b00, GREEN = 2'b01, YELLOW = 2'b10;
    localparam [1:0] S_MG = 2'd0, S_MY = 2'd1, S_SG = 2'd2, S_SY = 2'd3;

    reg [1:0]  state;
    reg [31:0] cnt;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_MG; cnt <= MAIN_GREEN;
        end else if (cnt == 32'd1) begin
            case (state)
                S_MG: begin state <= S_MY; cnt <= MAIN_YELLOW; end
                S_MY: begin state <= S_SG; cnt <= SIDE_GREEN;  end
                S_SG: begin state <= S_SY; cnt <= SIDE_YELLOW; end
                S_SY: begin state <= S_MG; cnt <= MAIN_GREEN;  end
                default: begin state <= S_MG; cnt <= MAIN_GREEN; end
            endcase
        end else begin
            cnt <= cnt - 32'd1;
        end
    end

    always @(*) begin
        case (state)
            S_MG: begin main_light = GREEN;  side_light = RED;    end
            S_MY: begin main_light = YELLOW; side_light = RED;    end
            S_SG: begin main_light = RED;    side_light = GREEN;  end
            S_SY: begin main_light = RED;    side_light = YELLOW; end
            default: begin main_light = RED; side_light = RED;    end
        endcase
    end
endmodule

// ---------------------------------------------------------------------------
// Self-checking testbench
// ---------------------------------------------------------------------------
module tb_tlc_checked;
    reg        clk, rst_n;
    wire [1:0] main_light, side_light;
    integer    errors = 0;

    localparam [1:0] GREEN = 2'b01;

    tlc_checked dut (
        .clk(clk), .rst_n(rst_n),
        .main_light(main_light), .side_light(side_light)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Safety check: after reset, both roads must never show green together
    always @(posedge clk) begin
        if (rst_n && main_light == GREEN && side_light == GREEN) begin
            errors = errors + 1;
            $display("t=%0t  ERROR: both roads green!", $time);
        end
    end

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;
        #400;                    // several full cycles
        if (errors == 0)
            $display("PASS: the two roads were never green at the same time.");
        else
            $display("FAIL: %0d conflicting-green events detected.", errors);
        $finish;
    end
endmodule

