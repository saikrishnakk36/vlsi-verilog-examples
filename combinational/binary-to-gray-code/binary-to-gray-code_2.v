// bin2gray.v - same converter, instantiated at WIDTH=8
module bin2gray #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] bin,
    output wire [WIDTH-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

// tb_bin2gray_wide.v - override WIDTH to 8, check a few landmark values
module tb_bin2gray_wide;
    localparam WIDTH = 8;
    reg  [WIDTH-1:0] bin;
    wire [WIDTH-1:0] gray;

    bin2gray #(.WIDTH(WIDTH)) dut (.bin(bin), .gray(gray));

    task show;
        input [WIDTH-1:0] value;
        begin
            bin = value;
            #1;
            $display("%3d : %b -> %b", bin, bin, gray);
        end
    endtask

    initial begin
        $display("8-bit binary -> gray (adjacent values differ by 1 bit)");
        $display("-----------------------------------------------------");
        show(8'd0);
        show(8'd1);
        show(8'd2);
        show(8'd3);
        show(8'd127);
        show(8'd128);
        show(8'd255);
        $finish;
    end
endmodule
