module tb;
  string name;
  string loud;
  initial begin
    name = "ChipXpert";

    loud = name.toupper();        // returns "CHIPXPERT"; name unchanged
    $display("%s -> %s", name, loud);
    $display("lower = %s", name.tolower());

    // getc reads a byte, putc overwrites one position
    $display("getc(0) = %c", name.getc(0));
    name.putc(0, "c");
    $display("after putc = %s", name);

    // compare: 0 means equal; icompare ignores case
    $display("compare  = %0d", name.compare("cHIPXPERT"));
    $display("icompare = %0d", name.icompare("CHIPXPERT"));
    $finish;
  end
endmodule
