# **MIPS-CPU**

This repository contains a MIPS CPU originally developed as part of a Computer Architecture and Design lab. The initial implementation is a single-cycle CPU, validated through Modelsim simulations and FPGA testing.
Here we will attempt to extend and enhance that base design beyond the original lab requirements.

<p align="center">
  <img width="1000" alt="image" src="https://github.com/user-attachments/assets/77db1384-27f3-4dd7-b8c5-51f68eaf51c0" />
</p>

## Origin

The initial implementation was developed for a university lab.
Details about the original CPU design and testing can be found in the lab report located under the `docs/` directory.

All new work in this repository builds on top of that base implementation.

## Structure

`src/` — VHDL source files

`sim/` — ModelSim testbenches and scripts

`constraints/` — Vivado XDC files

`docs/` — Documentation and lab report

## ModelSim

- Open ModelSim and click Compile.
- Select all VHDL source files from the src directory and compile them.
- After successful compilation, click Simulate.
- Open the work library, select the CPU entity, and start the simulation.
- In the ModelSim terminal, run the simulation script by typing `do ./sim/<testbench_name>.do`.
- The waveform window should open and display the simulation signals for analysis.

## Vivado

- Open Vivado and create a new project outside this repository.
- When adding sources, add all VHDL files from the src directory and make sure “Copy sources into project” is not checked so the files are referenced directly.
- Add the constraint file from the constraints directory.
- Once sources and constraints are added, run synthesis and implementation as usual, or just run Bitstream directly.

## Future Work

Planned improvements include:

- Pipelining
- Hazard handling
- Forwarding logic

**Note:** This project is set up for a Basys 3 board, so the XDC file and Vivado project settings should match the Basys 3 device and clock configuration.

<p align="center">
  <img width="500" alt="image" src="https://github.com/user-attachments/assets/94911193-85e8-4d63-88a0-c1634c602a38" />
</p>

