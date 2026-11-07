// 4-bit ALU: add/sub/and/or/xor/slt selected by a 3-bit opcode.
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

    reg [4:0] ext;   // one extra bit to hold carry / borrow

    always @(*) begin
        y     = 4'b0000;   // defaults keep the block purely combinational
        carry = 1'b0;
        ext   = 5'b00000;
        case (opcode)
            OP_ADD: begin
                ext   = {1'b0, a} + {1'b0, b};
                y     = ext[3:0];
                carry = ext[4];
            end
            OP_SUB: begin
                ext   = {1'b0, a} - {1'b0, b};
                y     = ext[3:0];
                carry = ext[4];          // 1 => a borrow was needed
            end
            OP_AND: y = a & b;
            OP_OR : y = a | b;
            OP_XOR: y = a ^ b;
            OP_SLT: y = ($signed(a) < $signed(b)) ? 4'd1 : 4'd0;
            default: y = 4'b0000;
        endcase
    end

    assign zero = (y == 4'b0000);
endmodule

// Testbench: one representative vector per operation.
module tb_alu4;
    reg  [3:0] a, b;
    reg  [2:0] opcode;
    wire [3:0] y;
    wire       carry, zero;

    alu4 dut (.a(a), .b(b), .opcode(opcode), .y(y), .carry(carry), .zero(zero));

    initial begin
        a=4'b0110; b=4'b0101; opcode=3'b000; #1
          $display("ADD a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b1001; b=4'b1000; opcode=3'b000; #1
          $display("ADD a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b0111; b=4'b0010; opcode=3'b001; #1
          $display("SUB a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b0010; b=4'b0101; opcode=3'b001; #1
          $display("SUB a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b1100; b=4'b1010; opcode=3'b010; #1
          $display("AND a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b1100; b=4'b1010; opcode=3'b011; #1
          $display("OR  a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b1100; b=4'b1010; opcode=3'b100; #1
          $display("XOR a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b1111; b=4'b0001; opcode=3'b101; #1
          $display("SLT a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        a=4'b0011; b=4'b0011; opcode=3'b100; #1
          $display("XOR a=%b b=%b -> y=%b (%0d) carry=%b zero=%b", a,b,y,y,carry,zero);
        $finish;
    end
endmodule

