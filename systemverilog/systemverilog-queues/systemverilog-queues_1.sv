module tb;
  // A queue of ints: the $ means "unbounded"
  int job_queue[$];
  int head, tail;

  initial begin
    job_queue.push_back(10);   // add at the tail
    job_queue.push_back(20);
    job_queue.push_front(5);   // add at the head
    // Queue now reads: {5, 10, 20}

    $display("size      = %0d", job_queue.size());
    $display("front     = %0d", job_queue[0]);
    $display("back      = %0d", job_queue[$]);   // $ indexes the last element

    head = job_queue.pop_front();  // removes and returns 5
    tail = job_queue.pop_back();   // removes and returns 20
    $display("popped head = %0d, tail = %0d", head, tail);
    $display("remaining size = %0d", job_queue.size());
    $finish;
  end
endmodule
