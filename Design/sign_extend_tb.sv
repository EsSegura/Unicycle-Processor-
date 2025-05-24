`timescale 1ns/1ps

module tb_sign_extend;

    // Testbench signals
    logic signed [11:0] tb_imm_in;
    logic signed [31:0] tb_imm_out;

    // Instantiate the DUT
    sign_extend dut (
        .imm_in(tb_imm_in),
        .imm_out(tb_imm_out)
    );

    initial begin
        $display("Time |     imm_in (12-bit)     |       imm_out (32-bit)");
        $display("--------------------------------------------------------");

        // Test case 1: Positive value
        tb_imm_in = 12'd25;
        #1 $display("%4t | %b (%0d) | %b (%0d)", $time, tb_imm_in, tb_imm_in, tb_imm_out, tb_imm_out);

        // Test case 2: Negative value
        tb_imm_in = -12'sd13;
        #1 $display("%4t | %b (%0d) | %b (%0d)", $time, tb_imm_in, tb_imm_in, tb_imm_out, tb_imm_out);

        // Test case 3: Max positive value (2047)
        tb_imm_in = 12'd2047;
        #1 $display("%4t | %b (%0d) | %b (%0d)", $time, tb_imm_in, tb_imm_in, tb_imm_out, tb_imm_out);

        // Test case 4: Most negative value (-2048)
        tb_imm_in = -12'sd2048;
        #1 $display("%4t | %b (%0d) | %b (%0d)", $time, tb_imm_in, tb_imm_in, tb_imm_out, tb_imm_out);

        // Done
        $finish;
    end

endmodule