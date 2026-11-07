module priority_encoder_casez (
    input  wire [7:0] req,
    output reg  [2:0] code,
    output reg        valid
);
    always @(*) begin
        valid = 1'b1;
        casez (req)                    // ? means "don't care" in casez
            8'b1???_????: code = 3'd7;
            8'b01??_????: code = 3'd6;
            8'b001?_????: code = 3'd5;
            8'b0001_????: code = 3'd4;
            8'b0000_1???: code = 3'd3;
            8'b0000_01??: code = 3'd2;
            8'b0000_001?: code = 3'd1;
            8'b0000_0001: code = 3'd0;
            default: begin code = 3'd0; valid = 1'b0; end
        endcase
    end
endmodule

module tb_priority_encoder_casez;
    reg  [7:0] req;
    wire [2:0] code;
    wire       valid;
    integer    i;
    integer    errors;
    reg  [3:0] exp;
    reg        ok;

    priority_encoder_casez dut (.req(req), .code(code), .valid(valid));

    // reference: index of the most significant set bit, 8 means "none"
    function [3:0] msb_index;
        input [7:0] v;
        integer k;
        begin
            msb_index = 4'd8;
            for (k = 0; k < 8; k = k + 1)
                if (v[k]) msb_index = k[3:0];
        end
    endfunction

    initial begin
        errors = 0;
        $display(" req      | code valid | expected | result");
        $display("----------+------------+----------+-------");
        for (i = 0; i < 8; i = i + 1) begin
            // several bits set at once to stress priority tie-breaking
            req = (8'b1 << i) | (8'b1 << (i / 2));
            #5;
            exp = msb_index(req);
            ok  = (valid && (code === exp[2:0]));
            if (!ok) errors = errors + 1;
            $display(" %b |  %0d    %b   |    %0d     | %s",
                     req, code, valid, exp, ok ? "PASS" : "FAIL");
        end
        req = 8'b0000_0000;
        #5;
        ok = (valid == 1'b0);
        if (!ok) errors = errors + 1;
        $display(" %b |  %0d    %b   |  none    | %s",
                 req, code, valid, ok ? "PASS" : "FAIL");
        $display("----------+------------+----------+-------");
        if (errors == 0)
            $display("ALL CHECKS PASSED: casez encoder matches MSB-priority reference.");
        else
            $display("FAILURES: %0d", errors);
        $finish;
    end
endmodule
