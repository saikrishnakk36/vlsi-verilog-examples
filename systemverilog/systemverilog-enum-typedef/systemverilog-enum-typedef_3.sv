module tb;
  typedef enum logic [2:0] {
    IDLE, FETCH, DECODE, EXECUTE, WRITEBACK
  } state_t;

  state_t st;
  int     i;

  initial begin
    st = st.first();
    for (i = 0; i < st.num(); i++) begin
      $display("state[%0d] = %-9s (encoding %0d)", i, st.name(), st);
      st = st.next();
    end
    $finish;
  end
endmodule
