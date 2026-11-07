module tb;
  // 'ref' passes the actual variable, so updates are visible immediately
  task automatic push_all(ref int q[$], input int values[]);
    foreach (values[i])
      q.push_back(values[i]);   // the caller's queue grows in place
  endtask

  // 'const ref' avoids copying a large array but forbids modifying it
  function automatic int sum_all(const ref int data[]);
    int total = 0;
    foreach (data[i])
      total += data[i];
    return total;
  endfunction
endmodule
