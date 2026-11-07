// tlc_allred.v  -  Verilog-2005
// Traffic light controller with a one-tick "all-red" clearance interval
// between phases, and an internal tick generator (clock divider) so the
// durations below are expressed in ticks rather than raw clock cycles.

module tlc_allred #(
    parameter integer CLKS_PER_TICK = 4,  // clocks that make up one "tick"
    parameter integer MAIN_GREEN     = 4,
    parameter integer MAIN_YELLOW    = 2,
    parameter integer SIDE_GREEN     = 3,
    parameter integer SIDE_YELLOW    = 2,
    parameter integer ALL_RED        = 1
) (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [1:0] main_light,
    output reg  [1:0] side_light
);

    localparam [1:0] RED = 2'b00, GREEN = 2'b01, YELLOW = 2'b10;

    localparam [2:0] S_MG = 3'd0,  // main green
                     S_MY = 3'd1,  // main yellow
                     S_AR1 = 3'd2, // all red (main -> side)
                     S_SG = 3'd3,  // side green
                     S_SY = 3'd4,  // side yellow
                     S_AR2 = 3'd5; // all red (side -> main)

    // --- Tick generator: one-clock pulse every CLKS_PER_TICK clocks ---
    reg [31:0] div;
    wire       tick = (div == CLKS_PER_TICK - 1);
    always @(posedge clk) begin
        if (!rst_n)      div <= 32'd0;
        else if (tick)   div <= 32'd0;
        else             div <= div + 32'd1;
    end

    // --- State and per-state tick counter ---
    reg [2:0]  state;
    reg [31:0] cnt;

    // Ticks the current state should last
    reg [31:0] dwell;
    always @(*) begin
        case (state)
            S_MG:  dwell = MAIN_GREEN;
            S_MY:  dwell = MAIN_YELLOW;
            S_AR1: dwell = ALL_RED;
            S_SG:  dwell = SIDE_GREEN;
            S_SY:  dwell = SIDE_YELLOW;
            S_AR2: dwell = ALL_RED;
            default: dwell = MAIN_GREEN;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_MG;
            cnt   <= MAIN_GREEN;
        end else if (tick) begin
            if (cnt == 32'd1) begin
                case (state)
                    S_MG:  begin state <= S_MY;  cnt <= MAIN_YELLOW; end
                    S_MY:  begin state <= S_AR1; cnt <= ALL_RED;     end
                    S_AR1: begin state <= S_SG;  cnt <= SIDE_GREEN;  end
                    S_SG:  begin state <= S_SY;  cnt <= SIDE_YELLOW; end
                    S_SY:  begin state <= S_AR2; cnt <= ALL_RED;     end
                    S_AR2: begin state <= S_MG;  cnt <= MAIN_GREEN;  end
                    default: begin state <= S_MG; cnt <= MAIN_GREEN; end
                endcase
            end else begin
                cnt <= cnt - 32'd1;
            end
        end
    end

    // Moore outputs
    always @(*) begin
        case (state)
            S_MG:  begin main_light = GREEN;  side_light = RED;    end
            S_MY:  begin main_light = YELLOW; side_light = RED;    end
            S_SG:  begin main_light = RED;    side_light = GREEN;  end
            S_SY:  begin main_light = RED;    side_light = YELLOW; end
            default: begin main_light = RED;  side_light = RED;    end // both all-red states
        endcase
    end

endmodule

// ---------------------------------------------------------------------------
// Testbench
// ---------------------------------------------------------------------------
module tb_tlc_allred;

    reg        clk;
    reg        rst_n;
    wire [1:0] main_light, side_light;

    tlc_allred #(
        .CLKS_PER_TICK(2),
        .MAIN_GREEN(4),
        .MAIN_YELLOW(2),
        .SIDE_GREEN(3),
        .SIDE_YELLOW(2),
        .ALL_RED(1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .main_light(main_light),
        .side_light(side_light)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    function [47:0] decode;
        input [1:0] light;
        case (light)
            2'b00:   decode = "RED   ";
            2'b01:   decode = "GREEN ";
            2'b10:   decode = "YELLOW";
            default: decode = "??????";
        endcase
    endfunction

    always @(main_light or side_light)
        $display("t=%0t  MAIN=%s  SIDE=%s",
                 $time, decode(main_light), decode(side_light));

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;
        #560;                 // one full cycle = 26 ticks * 2 clks * 10 = 520
        $display("Simulation finished.");
        $finish;
    end

endmodule

