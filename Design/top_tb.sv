//`timescale 1ns/1ps
/*
module top_tb;

    // Testbench signals
    logic             tb_clk;
    logic             tb_rst;
    logic [31:0] pc_out_tb;

    // Instantiate the DUT
    top dut (
        .clk(tb_clk),
        .rst(tb_rst),
        .pc_out(pc_out_tb)
    );

    always begin
        #5 tb_clk = !tb_clk;
    end

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb); 

        $monitor("Time: %d, Instruction: %b, PC actual: %d, Next_PC: %d", $time, dut.instr, pc_out_tb, dut.uut.next_pc);
        tb_clk = 0;
        tb_rst = 1;
        #10;
        tb_rst = 0;
        #10;
        #10;
        #10;
        #10;
        #10;
    end

endmodule */

module top_tb;

    // Parameters
    parameter WIDTH = 32;
    parameter DEPTH = 20;

    // Signals
    logic clk;
    logic rst;
    logic [WIDTH-1:0] pc_out;

    // Instantiate the top module
    top #(WIDTH, DEPTH) dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #35 clk = ~clk; // 10 time units clock period
    end

    // Testbench stimulus
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb); 
        rst = 1; // Assert reset
        #35;
        rst = 0; // Deassert reset

        // Add more test cases as needed
        #1000; // Wait for some time to observe behavior

        $finish; // End simulation
    end
    // Monitor outputs
    initial begin
        $monitor("Time: %0t, Instruction: %b, PC actual: %d, Next_PC: %d", $time, dut.instr, pc_out, dut.next_pc);
    end 
endmodule
