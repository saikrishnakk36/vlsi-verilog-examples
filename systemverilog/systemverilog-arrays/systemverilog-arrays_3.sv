module tb;
  int age [string];
  initial begin
    age["arjun"]  = 21;
    age["bhavya"] = 23;
    age["chetan"] = 20;
    $display("entries      = %0d", age.num());
    $display("bhavya       = %0d", age["bhavya"]);
    $display("has 'dev'?   = %0d", age.exists("dev"));
    foreach (age[name])
      $display("  %s -> %0d", name, age[name]);
    age.delete("chetan");
    $display("after delete = %0d entries", age.num());
    $finish;
  end
endmodule
