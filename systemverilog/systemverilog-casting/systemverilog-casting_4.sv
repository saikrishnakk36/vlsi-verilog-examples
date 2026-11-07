module tb;
  class Animal;
  endclass
  class Dog extends Animal;
    function void bark();
      $display("woof");
    endfunction
  endclass
  class Cat extends Animal;
  endclass

  initial begin
    Animal a;
    Dog    d;
    Cat    k;
    int    ok;
    k = new();
    a = k;                 // a now points at a Cat object
    ok = $cast(d, a);      // view that Cat through a Dog handle
    if (ok) d.bark();
    else    $display("cast failed, ok = 0, d stays null");
  end
endmodule
