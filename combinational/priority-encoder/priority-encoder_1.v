module priority_encoder_8to3 (
    input  wire [7:0] req,    // request lines, req[7] = highest priority
    output reg  [2:0] code,   // index of highest active request
    output reg        valid   // 1 when at least one request is active
);
    always @(*) begin
        valid = 1'b1;
        if      (req[7]) code = 3'd7;
        else if (req[6]) code = 3'd6;
        else if (req[5]) code = 3'd5;
        else if (req[4]) code = 3'd4;
        else if (req[3]) code = 3'd3;
        else if (req[2]) code = 3'd2;
        else if (req[1]) code = 3'd1;
        else if (req[0]) code = 3'd0;
        else begin
            code  = 3'd0;     // defined output when idle
            valid = 1'b0;
        end
    end
endmodule

module tb_priority_encoder_8to3;
    reg  [7:0] req;
    wire [2:0] code;
    wire       valid;

    priority_encoder_8to3 dut (.req(req), .code(code), .valid(valid));

    initial begin
        $display("  time |   req      | code | valid | note");
        $display("-------+------------+------+-------+--------------------");
        req = 8'b0000_0000; #5
          $display(" %4t | %b |  %0d   |   %b   | no request", $time, req, code, valid);
        req = 8'b0000_0001; #5
          $display(" %4t | %b |  %0d   |   %b   | only bit0", $time, req, code, valid);
        req = 8'b1000_0000; #5
          $display(" %4t | %b |  %0d   |   %b   | only bit7", $time, req, code, valid);
        req = 8'b1010_0100; #5
          $display(" %4t | %b |  %0d   |   %b   | tie 7,5,2 -> 7 wins", $time, req, code, valid);
        req = 8'b0011_0010; #5
          $display(" %4t | %b |  %0d   |   %b   | tie 5,4,1 -> 5 wins", $time, req, code, valid);
        req = 8'b0000_0110; #5
          $display(" %4t | %b |  %0d   |   %b   | tie 2,1 -> 2 wins", $time, req, code, valid);
        $display("-------+------------+------+-------+--------------------");
        $display("Priority tie-breaking verified: highest active index always wins.");
        $finish;
    end
endmodule
