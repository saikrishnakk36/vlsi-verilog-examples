module tb;
  // function that computes and returns a value
  function int square(int x);
    return x * x;
  endfunction

  // void function: does work, returns nothing
  function void show(string label, int val);
    $display("%-12s = %0d", label, val);
  endfunction

  initial begin
    int a;
    int r;
    a = 5;
    r = square(a);
    show("square(5)", r);
    show("square(9)", square(9));   // call used as an expression
    $finish;
  end
endmodule
