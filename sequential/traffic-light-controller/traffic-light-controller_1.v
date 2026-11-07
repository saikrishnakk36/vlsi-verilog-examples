// traffic_light.v  -  Verilog-2005
// Four-state traffic light controller for a main road and a side road.
// Durations are parameters, so you can retune the timing without rewiring.

module traffic_light #(
    parameter integer MAIN_GREEN_TICKS = 6,
    parameter integer MAIN_YEL_TICKS   = 2,
    parameter integer SIDE_GREEN_TICKS = 4,
    parameter integer SIDE_YEL_TICKS   = 2
) (
    input  wire       clk,
    input  wire       rst_n,      // active-low synchronous reset
    output reg  [1:0] main_light, // 2'b00 RED, 2'b01 GREEN, 2'b10 YELLOW
    output reg  [1:0] side_light
);

    // Light encodings
    localparam [1:0] RED = 2'b00, GREEN = 2'b01, YELLOW = 2'b10;

    // State encodings
    localparam [1:0] S_MAIN_GREEN = 2'd0,
                     S_MAIN_YEL   = 2'd1,
                     S_SIDE_GREEN = 2'd2,
                     S_SIDE_YEL   = 2'd3;

    reg [1:0]  state, next_state;
    reg [31:0] cnt;                 // down-counter of ticks left in the state

    // How many ticks the current state should last
    reg [31:0] dwell;
    always @(*) begin
        case (state)
            S_MAIN_GREEN: dwell = MAIN_GREEN_TICKS;
            S_MAIN_YEL:   dwell = MAIN_YEL_TICKS;
            S_SIDE_GREEN: dwell = SIDE_GREEN_TICKS;
            S_SIDE_YEL:   dwell = SIDE_YEL_TICKS;
            default:      dwell = MAIN_GREEN_TICKS;
        endcase
    end

    // Next-state logic: advance only when the counter has expired
    always @(*) begin
        next_state = state;
        if (cnt == 32'd1) begin
            case (state)
                S_MAIN_GREEN: next_state = S_MAIN_YEL;
                S_MAIN_YEL:   next_state = S_SIDE_GREEN;
                S_SIDE_GREEN: next_state = S_SIDE_YEL;
                S_SIDE_YEL:   next_state = S_MAIN_GREEN;
                default:      next_state = S_MAIN_GREEN;
            endcase
        end
    end

    // Sequential block: state register and tick counter
    always @(posedge clk) begin
        if (!rst_n) begin
            state <= S_MAIN_GREEN;
            cnt   <= MAIN_GREEN_TICKS;
        end else if (cnt == 32'd1) begin
            state <= next_state;
            // Preload the counter for the state we are about to enter
            case (next_state)
                S_MAIN_GREEN: cnt <= MAIN_GREEN_TICKS;
                S_MAIN_YEL:   cnt <= MAIN_YEL_TICKS;
                S_SIDE_GREEN: cnt <= SIDE_GREEN_TICKS;
                S_SIDE_YEL:   cnt <= SIDE_YEL_TICKS;
                default:      cnt <= MAIN_GREEN_TICKS;
            endcase
        end else begin
            cnt <= cnt - 32'd1;
        end
    end

    // Output logic (Moore): outputs depend only on the current state
    always @(*) begin
        case (state)
            S_MAIN_GREEN: begin main_light = GREEN;  side_light = RED;    end
            S_MAIN_YEL:   begin main_light = YELLOW; side_light = RED;    end
            S_SIDE_GREEN: begin main_light = RED;    side_light = GREEN;  end
            S_SIDE_YEL:   begin main_light = RED;    side_light = YELLOW; end
            default:      begin main_light = RED;    side_light = RED;    end
        endcase
    end

endmodule

// ---------------------------------------------------------------------------
// Testbench
// ---------------------------------------------------------------------------
module tb_traffic_light;

    reg        clk;
    reg        rst_n;
    wire [1:0] main_light, side_light;

    // Short durations keep the simulation fast
    traffic_light #(
        .MAIN_GREEN_TICKS(6),
        .MAIN_YEL_TICKS(2),
        .SIDE_GREEN_TICKS(4),
        .SIDE_YEL_TICKS(2)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .main_light(main_light),
        .side_light(side_light)
    );

    // 10-time-unit clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Turn a 2-bit light code into a readable word
    function [47:0] decode;
        input [1:0] light;
        case (light)
            2'b00:   decode = "RED   ";
            2'b01:   decode = "GREEN ";
            2'b10:   decode = "YELLOW";
            default: decode = "??????";
        endcase
    endfunction

    // Print one line every time either light changes
    always @(main_light or side_light)
        $display("t=%0t  MAIN=%s  SIDE=%s",
                 $time, decode(main_light), decode(side_light));

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;        // hold reset across the first clock edge
        #280;                    // run through more than one full cycle
        $display("Simulation finished.");
        $finish;
    end

endmodule

