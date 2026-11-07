module tb;
  bit [31:0] packed_word;
  byte unpacked_bytes [4];
  bit [7:0] matrix [3][4];
  initial begin
    packed_word = 32'hDEAD_BEEF;
    $display("packed_word      = %h", packed_word);
    $display("byte[1] (15:8)   = %h", packed_word[15:8]);
    unpacked_bytes = '{8'h11, 8'h22, 8'h33, 8'h44};
    $display("unpacked_bytes[2]= %h", unpacked_bytes[2]);
    foreach (matrix[r, c])
      matrix[r][c] = r*10 + c;
    $display("matrix[2][3]     = %0d", matrix[2][3]);
    $finish;
  end
endmodule
