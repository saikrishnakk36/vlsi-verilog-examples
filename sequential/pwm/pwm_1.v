// pwm_basic.v -- parameterized counter-compare PWM generator
module pwm_generator #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire [WIDTH-1:0] duty,
    output reg              pwm_out
);
    reg [WIDTH-1:0] counter;

    // free-running counter, wraps naturally at 2**WIDTH
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= {WIDTH{1'b0}};
        else
            counter <= counter + 1'b1;
    end

    // registered compare: output is high while counter is below the threshold
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_out <= 1'b0;
        else
            pwm_out <= (counter < duty);
    end
endmodule

// ---------------- testbench ----------------
module tb_pwm_basic;
    localparam WIDTH  = 4;             // 16-step period: short for simulation
    localparam PERIOD = (1 << WIDTH);

    reg              clk;
    reg              rst_n;
    reg  [WIDTH-1:0] duty;
    wire             pwm_out;
    integer          i;
    integer          high_count;

    pwm_generator #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .duty(duty), .pwm_out(pwm_out)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;              // 10-time-unit clock

    initial begin
        duty  = 4'd4;                  // request 4 / 16 = 25%
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;                  // release reset

        high_count = 0;
        for (i = 0; i < PERIOD; i = i + 1) begin
            @(posedge clk);
            if (pwm_out) high_count = high_count + 1;
            $display("t=%0t  cycle=%0d  pwm_out=%b", $time, i, pwm_out);
        end

        $display("requested duty = %0d/%0d, measured high cycles = %0d/%0d",
                 duty, PERIOD, high_count, PERIOD);
        $finish;
    end
endmodule

