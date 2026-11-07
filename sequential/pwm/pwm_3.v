// pwm_sync.v -- PWM generator that latches a new duty only at the period boundary
module pwm_sync #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] duty,
    output reg              pwm_out
);
    reg  [WIDTH-1:0] counter;
    reg  [WIDTH-1:0] duty_latched;
    wire             period_end = (counter == {WIDTH{1'b1}});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= {WIDTH{1'b0}};
        else
            counter <= counter + 1'b1;
    end

    // double-buffer: sample the live duty only when the counter is about to wrap
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            duty_latched <= {WIDTH{1'b0}};
        else if (period_end)
            duty_latched <= duty;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_out <= 1'b0;
        else
            pwm_out <= (counter < duty_latched);
    end
endmodule

// ---------------- testbench ----------------
module tb_pwm_sync;
    localparam WIDTH = 4;

    reg              clk;
    reg              rst_n;
    reg  [WIDTH-1:0] duty;
    wire             pwm_out;
    integer          periods;

    pwm_sync #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .duty(duty), .pwm_out(pwm_out)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n   = 1'b0;
        duty    = 4'd4;                // start by requesting 25%
        periods = 0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;

        $display("t     cnt  duty_in  duty_latched  pwm");
        repeat (50) begin
            @(posedge clk);
            #1;                        // settle after non-blocking updates
            $display("%4t   %2d     %2d        %2d         %b",
                     $time, dut.counter, duty, dut.duty_latched, pwm_out);
            if (dut.counter == 4'd15)
                periods = periods + 1;
            // request 75% midway through the second period:
            // it must NOT take effect until the next wrap
            if (periods == 1 && dut.counter == 4'd6)
                duty = 4'd12;
        end
        $finish;
    end
endmodule

