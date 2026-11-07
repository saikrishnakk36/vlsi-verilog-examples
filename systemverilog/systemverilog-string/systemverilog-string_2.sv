module tb;
  string field;
  string num_txt;
  string rebuilt;
  int    value;

  initial begin
    field = "speed=250";

    // Pull the numeric part out with substr, then convert with atoi()
    num_txt = field.substr(6, 8);
    value   = num_txt.atoi();
    $display("field   = %s", field);
    $display("num_txt = %s", num_txt);
    $display("value   = %0d", value);
    $display("doubled = %0d", value * 2);

    // itoa() writes an integer into a string (modifies in place)
    rebuilt.itoa(value * 2);
    $display("rebuilt = %s (len %0d)", rebuilt, rebuilt.len());

    // atohex() reads hex digits; handy for parsing register dumps
    num_txt = "1a5";
    value   = num_txt.atohex();
    $display("atohex(1a5) = %0d", value);
    $finish;
  end
endmodule
