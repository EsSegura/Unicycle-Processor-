# Makefile for sign extension simulation

# Toolchain
VLOG = iverilog
VVP  = vvp

# Files
SRC = sign_extend.sv
TB  = sign_extend_tb.sv
OUT = sign_extend_tb

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
