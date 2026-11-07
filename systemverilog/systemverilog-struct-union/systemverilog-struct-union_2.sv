module tb;
  // unpacked struct: members stored separately, not as one vector
  typedef struct {
    int    id;
    string name;
    real   score;
  } student_t;

  student_t s;

  initial begin
    // named assignment pattern fills every member at once
    s = '{id: 7, name: "Asha", score: 91.5};
    $display("id=%0d name=%s score=%0.1f", s.id, s.name, s.score);
  end
endmodule

