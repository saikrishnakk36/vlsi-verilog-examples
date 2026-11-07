module tb;
  int data [] = '{5, 2, 8, 2, 9, 1};
  int res  [$];
  int idx  [$];
  initial begin
    $display("sum = %0d", data.sum());
    res = data.find with (item > 4);
    $write("find > 4   :"); foreach (res[i]) $write(" %0d", res[i]); $write("n");
    idx = data.find_index with (item == 2);
    $write("index of 2 :"); foreach (idx[i]) $write(" %0d", idx[i]); $write("n");
    data.sort();
    $write("sorted     :"); foreach (data[i]) $write(" %0d", data[i]); $write("n");
    data.rsort();
    $write("rsorted    :"); foreach (data[i]) $write(" %0d", data[i]); $write("n");
    res = data.unique();
    $write("unique     :"); foreach (res[i]) $write(" %0d", res[i]); $write("n");
    $finish;
  end
endmodule
