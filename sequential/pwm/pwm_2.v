// pwm_sweep.v -- parameterized PWM generator with a duty-cycle sweep testbench
module pwm_generator #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] duty,
    output reg              pwm_out
);
    reg [WIDTH-1:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= {WIDTH{1'b0}};
        else
            counter <= counter + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_out <= 1'b0;
        else
            pwm_out <= (counter < duty);
    end
endmodule

// ---------------- testbench ----------------
module tb_pwm_sweep;
    localparam WIDTH  = 4;
    localparam PERIOD = (1 << WIDTH);  // 16 clocks per PWM period

    reg              clk;
    reg              rst_n;
    reg  [WIDTH-1:0] duty;
    wire             pwm_out;
    integer          i, k;
    integer          high_count;
    reg  [WIDTH-1:0] test_duty [0:4];

    pwm_generator #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .duty(duty), .pwm_out(pwm_out)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        test_duty[0] = 4'd0;
        test_duty[1] = 4'd4;
        test_duty[2] = 4'd8;
        test_duty[3] = 4'd12;
        test_duty[4] = 4'd15;

        duty  = 4'd0;
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;

        $display("duty_in | high_cycles | measured_duty_%%");
        for (k = 0; k < 5; k = k + 1) begin
            duty = test_duty[k];
            @(posedge clk);            // let the new duty value settle
            high_count = 0;
            for (i = 0; i < PERIOD; i = i + 1) begin
                @(posedge clk);
                if (pwm_out) high_count = high_count + 1;
            end
            $display("  %2d    |     %2d      |      %3d",
                     duty, high_count, (high_count * 100) / PERIOD);
        end
        $finish;
    end
endmodule

