// 4-bit ALU (same design) with a self-checking testbench.
module alu4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] opcode,
    output reg  [3:0] y,
    output reg        carry,
    output wire       zero
);
    localparam OP_ADD = 3'b000,
               OP_SUB = 3'b001,
               OP_AND = 3'b010,
               OP_OR  = 3'b011,
               OP_XOR = 3'b100,
               OP_SLT = 3'b101;

    reg [4:0] ext;

    always @(*) begin
        y     = 4'b0000;
        carry = 1'b0;
        ext   = 5'b00000;
        case (opcode)
            OP_ADD: begin ext = {1'b0,a} + {1'b0,b}; y = ext[3:0]; carry = ext[4]; end
            OP_SUB: begin ext = {1'b0,a} - {1'b0,b}; y = ext[3:0]; carry = ext[4]; end
            OP_AND: y = a & b;
            OP_OR : y = a | b;
            OP_XOR: y = a ^ b;
            OP_SLT: y = ($signed(a) < $signed(b)) ? 4'd1 : 4'd0;
            default: y = 4'b0000;
        endcase
    end

    assign zero = (y == 4'b0000);
endmodule

// Self-checking testbench: compare the DUT against a reference model.
module tb_alu4_check;
    reg  [3:0] a, b;
    reg  [2:0] opcode;
    wire [3:0] y;
    wire       carry, zero;
    reg  [3:0] exp;
    integer    errors, i;

    alu4 dut (.a(a), .b(b), .opcode(opcode), .y(y), .carry(carry), .zero(zero));

    function [3:0] model(input [3:0] av, input [3:0] bv, input [2:0] op);
        case (op)
            3'b000: model = av + bv;
            3'b001: model = av - bv;
            3'b010: model = av & bv;
            3'b011: model = av | bv;
            3'b100: model = av ^ bv;
            3'b101: model = ($signed(av) < $signed(bv)) ? 4'd1 : 4'd0;
            default: model = 4'b0000;
        endcase
    endfunction

    task check;
        begin
            exp = model(a, b, opcode);
            if (y !== exp) begin
                errors = errors + 1;
                $display("MISMATCH op=%b a=%b b=%b got=%b exp=%b", opcode, a, b, y, exp);
            end else begin
                $display("ok  op=%b a=%b b=%b -> y=%b zero=%b", opcode, a, b, y, zero);
            end
        end
    endtask

    initial begin
        errors = 0;
        for (i = 0; i < 6; i = i + 1) begin
            opcode = i[2:0];
            a = 4'b1011; b = 4'b0110; #1 check;
            a = 4'b0100; b = 4'b0100; #1 check;
        end
        if (errors == 0) $display("RESULT: ALL CHECKS PASSED");
        else             $display("RESULT: %0d MISMATCH(ES)", errors);
        $finish;
    end
endmodule

