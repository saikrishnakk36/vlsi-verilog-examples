# VLSI Examples — Verilog, SystemVerilog & UVM

A library of **simulation-verified** hardware design examples: Verilog, SystemVerilog and UVM,
each a complete design with a self-checking testbench. Every verified file was compiled and run
before it was committed (Icarus Verilog for Verilog; Verilator 5 for SystemVerilog).

- `combinational/` — combinational Verilog designs (adders, mux/demux, encoders, multipliers, …)
- `sequential/` — sequential Verilog designs (counters, FIFOs, FSMs, SPI/I2C/AXI/APB, arbiters, CDC, …)
- `systemverilog/` — SystemVerilog language & verification examples
- `uvm/` — UVM reference (canonical UVM needs a UVM-capable simulator; verified plain-SystemVerilog
  companions are included where available)

See [INDEX.md](INDEX.md) for the full list with the matching tutorial page for each design.

Maintained by the [ChipXpert VLSI training team](https://chipxpert.in/).
