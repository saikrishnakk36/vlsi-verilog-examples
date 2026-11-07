module tb;
  class Shape;
    virtual function string kind();
      return "shape";
    endfunction
  endclass

  class Circle extends Shape;
    int radius;
    function new(int r);
      radius = r;
    endfunction
    function string kind();
      return "circle";
    endfunction
  endclass

  initial begin
    Shape  s;
    Circle c, c2;
    int    ok;
    c = new(5);
    s = c;                 // upcast: always legal, no cast needed
    ok = $cast(c2, s);     // downcast: s really holds a Circle -> ok = 1
    $display("downcast ok = %0d", ok);
    if (ok) $display("radius = %0d", c2.radius);
  end
endmodule
