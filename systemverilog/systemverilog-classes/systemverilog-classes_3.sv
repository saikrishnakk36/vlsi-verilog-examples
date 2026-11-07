module tb;
  class Stimulus;
    int v;
    function new();
      v = 0;
    endfunction
    virtual function int next();
      return 0;
    endfunction
  endclass

  class Counter extends Stimulus;
    virtual function int next();
      v = v + 1;
      return v;
    endfunction
  endclass

  class Doubler extends Stimulus;
    function new();
      super.new();
      v = 1;
    endfunction
    virtual function int next();
      v = v * 2;
      return v;
    endfunction
  endclass

  Stimulus gens[$];
  Counter  c;
  Doubler  d;
  int i, a, b;

  initial begin
    c = new();
    d = new();
    gens.push_back(c);
    gens.push_back(d);
    for (i = 0; i < gens.size(); i++) begin
      a = gens[i].next();
      b = gens[i].next();
      $display("gen[%0d]: first=%0d second=%0d", i, a, b);
    end
    $finish;
  end
endmodule
