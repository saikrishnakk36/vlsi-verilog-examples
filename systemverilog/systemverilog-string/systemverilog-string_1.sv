module tb;
  string tool;
  string msg;
  int    width;

  initial begin
    tool  = "ChipXpert";
    width = tool.len();              // number of characters

    $display("tool   = %s", tool);
    $display("length = %0d", width);

    // Concatenation reuses the { , } syntax of packed values
    msg = {"Welcome to ", tool, " labs"};
    $display("msg    = %s", msg);

    // Index one character: tool[i] is a byte holding the ASCII code
    $display("tool[0] = %0d (as char: %c)", tool[0], tool[0]);
    $display("last    = %c", tool[width-1]);

    // substr(i, j) extracts characters i..j inclusive
    $display("substr(0,3) = %s", tool.substr(0, 3));
    $display("substr(4,8) = %s", tool.substr(4, 8));
    $finish;
  end
endmodule
