# Makefile for sign extension simulation

# Toolchain
VLOG = iverilog
VVP  = vvp

# Files
SRC = imm_gen.sv
TB  = imm_gen_tb.sv
OUT = imm_gen_tb

# Default target
all: run

# Compile
compile:
	$(VLOG) -g2012 -o $(OUT) $(SRC) $(TB)

# Run simulation
run: compile
	$(VVP) $(OUT)

# Clean compiled files
clean:
	rm -f $(OUT) *.vcd
