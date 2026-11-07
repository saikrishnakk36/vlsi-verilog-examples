// Asynchronous (combinational) ROM using a case statement
module rom_async #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data
);
    always @(*) begin
        case (addr)
            3'd0: data = 8'h10;
            3'd1: data = 8'h32;
            3'd2: data = 8'h54;
            3'd3: data = 8'h76;
            3'd4: data = 8'h98;
            3'd5: data = 8'hBA;
            3'd6: data = 8'hDC;
            3'd7: data = 8'hFE;
            default: data = {DATA_WIDTH{1'b0}};
        endcase
    end
endmodule

module tb_rom_async;
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 3;

    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] data;
    integer i;

    rom_async #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
        .addr(addr),
        .data(data)
    );

    initial begin
        $display("ADDR  DATA");
        for (i = 0; i < 8; i = i + 1) begin
            addr = i[ADDR_WIDTH-1:0];
            #5;
            $display("  %0d   0x%02h", addr, data);
        end
        $finish;
    end
endmodule
