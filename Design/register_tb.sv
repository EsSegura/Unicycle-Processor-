`timescale 1ps/1ps

module register_tb;
    
    reg  clk_tb;
    reg  rst_tb;
    reg  write_tb;
    reg  enable_tb;
    reg  [31:0] data_in_tb;
    reg  [15:0] data_in_tb1;
    
    wire  [31:0] data_out_tb;
    wire  [15:0] data_out_tb1;

    register dut (
        .clk(clk_tb),
        .rst(rst_tb),
        .write(write_tb),
        .enable(enable_tb),
        .data_in(data_in_tb),
        .data_out(data_out_tb)
    );

    register #(.WIDTH(16)) dut2 (
        .clk(clk_tb),
        .rst(rst_tb),
        .write(write_tb),
        .enable(enable_tb),
        .data_in(data_in_tb1),
        .data_out(data_out_tb1)
    );

    always begin
        #5 clk_tb = !clk_tb;
    end

    initial begin
        $dumpfile("register.vcd");
        $dumpvars(0, register_tb);  

        clk_tb = 0;

        rst_tb = 0; write_tb = 0; enable_tb = 0; data_in_tb = 0; data_in_tb1 = 0;
        #10;
        rst_tb = 1; write_tb = 0; enable_tb = 0; data_in_tb = 0; data_in_tb1 = 0;
        #10;
        rst_tb = 0; write_tb = 0; enable_tb = 0; data_in_tb = 0; data_in_tb1 = 0;
        #20;
        rst_tb = 0; write_tb = 1; enable_tb = 0; data_in_tb = 25; data_in_tb1 = 30;
        #30;
        rst_tb = 0; write_tb = 0; enable_tb = 0; data_in_tb = 40; data_in_tb1 = 40;
        #20;
        rst_tb = 0; write_tb = 0; enable_tb = 1; data_in_tb = 62; data_in_tb1 = 0;
        #20;
        rst_tb = 0; write_tb = 0; enable_tb = 1; data_in_tb = 10; data_in_tb1 = 0;
        #100;
        $finish;
    end

endmodule