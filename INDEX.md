# VLSI Verilog / SystemVerilog / UVM Examples — Index

73 designs with simulation-verified code (197 verified source files), 15 reference-only topics (UVM library code — needs a UVM-capable simulator).

Every file marked **verified** was compiled and run before staging: Verilog with Icarus Verilog (`iverilog -g2005`), SystemVerilog with Verilator 5 + z3 (`--binary --timing`). UVM library code is not runnable on free tools and is listed as **reference** (full code lives on the linked page).

## Combinational (Verilog)

| Design | Status | Files | Tutorial page |
|---|---|---|---|
| 4-Bit ALU Verilog Code with Testbench (`combinational/alu/`) | verified | 2 | https://chipxpert.in/verilog/alu-verilog-code/ |
| Array Multiplier Verilog Code (`combinational/array-multiplier/`) | verified | 2 | https://chipxpert.in/verilog/array-multiplier-verilog-code/ |
| Barrel Shifter Verilog Code (Parameterized) (`combinational/barrel-shifter/`) | verified | 2 | https://chipxpert.in/verilog/barrel-shifter-verilog-code/ |
| Binary to Gray Code Verilog Code (`combinational/binary-to-gray-code/`) | verified | 3 | https://chipxpert.in/verilog/binary-to-gray-code-verilog/ |
| Booth Multiplier Verilog Code (`combinational/booth-multiplier/`) | verified | 2 | https://chipxpert.in/verilog/booth-multiplier-verilog-code/ |
| Carry Look-Ahead Adder Verilog Code (`combinational/carry-lookahead-adder/`) | verified | 3 | https://chipxpert.in/verilog/carry-lookahead-adder-verilog-code/ |
| Comparator Verilog Code (4-Bit) (`combinational/comparator/`) | verified | 2 | https://chipxpert.in/verilog/comparator-verilog-code/ |
| Decoder Verilog Code: 2-to-4 & 3-to-8 (`combinational/decoder/`) | verified | 3 | https://chipxpert.in/verilog/decoder-verilog-code/ |
| Demultiplexer Verilog Code: 1-to-4 Demux (`combinational/demultiplexer/`) | verified | 2 | https://chipxpert.in/verilog/demultiplexer-verilog-code/ |
| Full Adder Verilog Code (3 Styles) (`combinational/full-adder/`) | verified | 3 | https://chipxpert.in/verilog/full-adder-verilog-code/ |
| Half Adder Verilog Code (Tested) (`combinational/half-adder/`) | verified | 2 | https://chipxpert.in/verilog/half-adder-verilog-code/ |
| Parity Generator Verilog Code (Even/Odd) (`combinational/parity-generator/`) | verified | 3 | https://chipxpert.in/verilog/parity-generator-verilog-code/ |
| 8-to-3 Priority Encoder Verilog Code (`combinational/priority-encoder/`) | verified | 2 | https://chipxpert.in/verilog/priority-encoder-verilog-code/ |
| 7 Segment Display Verilog Code (`combinational/seven-segment-decoder/`) | verified | 3 | https://chipxpert.in/verilog/seven-segment-decoder-verilog-code/ |
| Verilog Code for 4:1 MUX (3 Styles) (`combinational/mux-4to1/`) | verified | 3 | https://chipxpert.in/verilog/verilog-code-for-4-to-1-mux/ |
| Wallace Tree Multiplier Verilog Code (`combinational/wallace-tree-multiplier/`) | verified | 2 | https://chipxpert.in/verilog/wallace-tree-multiplier-verilog-code/ |

## Sequential (Verilog)

| Design | Status | Files | Tutorial page |
|---|---|---|---|
| 4-Bit Up/Down Counter Verilog Code (`sequential/4-bit-counter/`) | verified | 2 | https://chipxpert.in/verilog/4-bit-counter-verilog-code/ |
| APB Slave Verilog Code: Write + Read Testbench (`sequential/apb-slave/`) | verified | 2 | https://chipxpert.in/verilog/apb-slave-verilog-code/ |
| Asynchronous FIFO Verilog Code (`sequential/asynchronous-fifo/`) | verified | 2 | https://chipxpert.in/verilog/asynchronous-fifo-verilog-code/ |
| AXI Lite Slave Verilog Code: Write & Read Demo (`sequential/axi-lite-slave/`) | verified | 2 | https://chipxpert.in/verilog/axi-lite-slave-verilog-code/ |
| BCD Counter Verilog Code & Testbench (`sequential/bcd-counter/`) | verified | 2 | https://chipxpert.in/verilog/bcd-counter-verilog-code/ |
| CDC Synchronizer Verilog Code (`sequential/cdc-synchronizer/`) | verified | 3 | https://chipxpert.in/verilog/cdc-synchronizer-verilog-code/ |
| Clock Divider Verilog Code (Div-2, N, Odd) (`sequential/clock-divider/`) | verified | 3 | https://chipxpert.in/verilog/clock-divider-verilog-code/ |
| CRC Verilog Code: Serial LFSR Generator (`sequential/crc/`) | verified | 3 | https://chipxpert.in/verilog/crc-verilog-code/ |
| D Flip-Flop Verilog Code (Async & Sync) (`sequential/d-flip-flop/`) | verified | 3 | https://chipxpert.in/verilog/d-flip-flop-verilog-code/ |
| Debounce Verilog Code: Counter Debouncer (`sequential/debounce-circuit/`) | verified | 2 | https://chipxpert.in/verilog/debounce-circuit-verilog-code/ |
| Dual-Port RAM Verilog Code (`sequential/dual-port-ram/`) | verified | 3 | https://chipxpert.in/verilog/dual-port-ram-verilog-code/ |
| Edge Detector Verilog Code Guide (`sequential/edge-detector/`) | verified | 2 | https://chipxpert.in/verilog/edge-detector-verilog-code/ |
| FIFO Verilog Code: Synchronous FIFO (`sequential/fifo/`) | verified | 1 | https://chipxpert.in/verilog/fifo-verilog-code/ |
| FSM Verilog Code: Mealy vs Moore (`sequential/fsm/`) | verified | 2 | https://chipxpert.in/verilog/fsm-verilog-code/ |
| Gray Code Counter Verilog Code (`sequential/gray-counter/`) | verified | 3 | https://chipxpert.in/verilog/gray-counter-verilog-code/ |
| Hamming Code Verilog Code (7,4) Encoder (`sequential/hamming-code/`) | verified | 3 | https://chipxpert.in/verilog/hamming-code-verilog-code/ |
| I2C Master Verilog Code: Build & Simulate (`sequential/i2c-master/`) | verified | 1 | https://chipxpert.in/verilog/i2c-master-verilog-code/ |
| Johnson Counter Verilog Code (`sequential/johnson-counter/`) | verified | 3 | https://chipxpert.in/verilog/johnson-counter-verilog-code/ |
| LFSR Verilog Code: Galois & Fibonacci (`sequential/lfsr/`) | verified | 3 | https://chipxpert.in/verilog/lfsr-verilog-code/ |
| Mod-N Counter Verilog Code + Testbench (`sequential/mod-n-counter/`) | verified | 3 | https://chipxpert.in/verilog/mod-n-counter-verilog-code/ |
| Priority Arbiter Verilog Code (`sequential/priority-arbiter/`) | verified | 3 | https://chipxpert.in/verilog/priority-arbiter-verilog-code/ |
| PWM Verilog Code: Parameterized Generator (`sequential/pwm/`) | verified | 3 | https://chipxpert.in/verilog/pwm-verilog-code/ |
| Ring Counter Verilog Code (4-bit) (`sequential/ring-counter/`) | verified | 2 | https://chipxpert.in/verilog/ring-counter-verilog-code/ |
| ROM Verilog Code: Sync & Async Examples (`sequential/rom/`) | verified | 3 | https://chipxpert.in/verilog/rom-verilog-code/ |
| Round Robin Arbiter Verilog Code (`sequential/round-robin-arbiter/`) | verified | 1 | https://chipxpert.in/verilog/round-robin-arbiter-verilog-code/ |
| Sequence Detector Verilog Code (`sequential/sequence-detector/`) | verified | 3 | https://chipxpert.in/verilog/sequence-detector-verilog-code/ |
| Shift Register Verilog Code (`sequential/shift-register/`) | verified | 4 | https://chipxpert.in/verilog/shift-register-verilog-code/ |
| Single-Port RAM Verilog Code Tutorial (`sequential/single-port-ram/`) | verified | 3 | https://chipxpert.in/verilog/single-port-ram-verilog-code/ |
| SPI Master Verilog Code: Mode-0 Design (`sequential/spi-master/`) | verified | 3 | https://chipxpert.in/verilog/spi-master-verilog-code/ |
| SPI Slave Verilog Code — Mode 0 (`sequential/spi-slave/`) | verified | 2 | https://chipxpert.in/verilog/spi-slave-verilog-code/ |
| T Flip-Flop Verilog Code + Testbench (`sequential/t-flip-flop/`) | verified | 2 | https://chipxpert.in/verilog/t-flip-flop-verilog-code/ |
| Traffic Light Controller Verilog Code (`sequential/traffic-light-controller/`) | verified | 3 | https://chipxpert.in/verilog/traffic-light-controller-verilog-code/ |
| UART Verilog Code: TX, RX, Baud & Testbench (`sequential/uart/`) | verified | 2 | https://chipxpert.in/verilog/uart-verilog-code/ |
| Up Down Counter Verilog Code (`sequential/updown-counter/`) | verified | 3 | https://chipxpert.in/verilog/updown-counter-verilog-code/ |

## SystemVerilog

| Design | Status | Files | Tutorial page |
|---|---|---|---|
| SystemVerilog Arrays: Packed to Associative (`systemverilog/systemverilog-arrays/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-arrays/ |
| SystemVerilog Assertions (SVA) Tutorial (`systemverilog/systemverilog-assertions/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-assertions/ |
| SystemVerilog Casting: $cast & Bit-Stream (`systemverilog/systemverilog-casting/`) | verified | 5 | https://chipxpert.in/systemverilog/systemverilog-casting/ |
| SystemVerilog Class & OOP Guide (`systemverilog/systemverilog-classes/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-classes/ |
| SystemVerilog Clocking Block: Sampling & Skew (`systemverilog/systemverilog-clocking-block/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-clocking-block/ |
| SystemVerilog Constraints & Randomization (`systemverilog/systemverilog-constraints/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-constraints/ |
| SystemVerilog Data Types Explained (`systemverilog/systemverilog-data-types/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-data-types/ |
| SystemVerilog enum and typedef Guide (`systemverilog/systemverilog-enum-typedef/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-enum-typedef/ |
| SystemVerilog Fork-Join & join_any Guide (`systemverilog/systemverilog-fork-join/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-fork-join/ |
| SystemVerilog Functional Coverage Guide (`systemverilog/systemverilog-functional-coverage/`) | verified | 2 | https://chipxpert.in/systemverilog/systemverilog-functional-coverage/ |
| SystemVerilog randomize with {} Guide (`systemverilog/systemverilog-inline-constraints/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-inline-constraints/ |
| SystemVerilog Interface Tutorial (`systemverilog/systemverilog-interface/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-interface/ |
| SystemVerilog Mailbox and Semaphore (`systemverilog/systemverilog-mailbox-semaphore/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-mailbox-semaphore/ |
| SystemVerilog Package: import, ::, Wildcard (`systemverilog/systemverilog-package/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-package/ |
| SystemVerilog Queue: Methods & Examples (`systemverilog/systemverilog-queues/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-queues/ |
| SystemVerilog Randomization Guide (`systemverilog/systemverilog-randomization/`) | verified | 5 | https://chipxpert.in/systemverilog/systemverilog-randomization/ |
| SystemVerilog String: Methods & Examples (`systemverilog/systemverilog-string/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-string/ |
| SystemVerilog Struct and Union Guide (`systemverilog/systemverilog-struct-union/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-struct-union/ |
| SystemVerilog Task Function Guide (`systemverilog/systemverilog-task-function/`) | verified | 4 | https://chipxpert.in/systemverilog/systemverilog-task-function/ |
| SystemVerilog Tutorial: Guide for DV Beginners (`systemverilog/systemverilog-tutorial/`) | verified | 3 | https://chipxpert.in/systemverilog/systemverilog-tutorial/ |

## UVM

| Design | Status | Files | Tutorial page |
|---|---|---|---|
| UVM Agent: Active vs Passive & is_active (—) | reference | 0 | https://chipxpert.in/uvm/uvm-agent/ |
| UVM Callback Tutorial: uvm_callbacks Hooks (`uvm/uvm-callbacks/`) | verified | 1 | https://chipxpert.in/uvm/uvm-callbacks/ |
| UVM config_db: set/get and Wildcards (—) | reference | 0 | https://chipxpert.in/uvm/uvm-config-db/ |
| UVM Driver: run_phase & item_done Handshake (—) | reference | 0 | https://chipxpert.in/uvm/uvm-driver/ |
| UVM env: build_phase, connect_phase, ports (`uvm/uvm-env/`) | verified | 1 | https://chipxpert.in/uvm/uvm-env/ |
| UVM Factory Explained with Examples (—) | reference | 0 | https://chipxpert.in/uvm/uvm-factory/ |
| UVM Monitor: Sample, Build & Broadcast (—) | reference | 0 | https://chipxpert.in/uvm/uvm-monitor/ |
| UVM Objection Guide: raise & drop (—) | reference | 0 | https://chipxpert.in/uvm/uvm-objections/ |
| UVM Phases Explained with Examples (—) | reference | 0 | https://chipxpert.in/uvm/uvm-phases/ |
| UVM RAL Tutorial with Examples (`uvm/uvm-ral/`) | verified | 1 | https://chipxpert.in/uvm/uvm-ral/ |
| UVM Reporting & Verbosity Explained (—) | reference | 0 | https://chipxpert.in/uvm/uvm-reporting/ |
| UVM Scoreboard: analysis_imp and write() (—) | reference | 0 | https://chipxpert.in/uvm/uvm-scoreboard/ |
| UVM Sequence and Sequencer Explained (—) | reference | 0 | https://chipxpert.in/uvm/uvm-sequence-sequencer/ |
| UVM Test Explained: uvm_test, env, objections (—) | reference | 0 | https://chipxpert.in/uvm/uvm-test/ |
| UVM Testbench Architecture Explained (—) | reference | 0 | https://chipxpert.in/uvm/uvm-testbench-architecture/ |
| UVM TLM Explained with Examples (—) | reference | 0 | https://chipxpert.in/uvm/uvm-tlm/ |
| UVM Tutorial: Hierarchy & First Steps (—) | reference | 0 | https://chipxpert.in/uvm/uvm-tutorial/ |
| UVM Virtual Sequence & Virtual Sequencer (—) | reference | 0 | https://chipxpert.in/uvm/uvm-virtual-sequence/ |
