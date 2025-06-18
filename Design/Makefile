# Makefile for sign extension simulation

# Toolchain
VLOG = iverilog
VVP  = vvp

# Files
SRC = top.sv
TB  = top_tb.sv
OUT = top_tb

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
