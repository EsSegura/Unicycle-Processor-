`timescale 1ns/1ns

module control_signal_tb #(parameter WIDTH = 32);

    logic [WIDTH-1:0] instruction_tb;
    logic              comparison_tb;
  
    logic          mux_pc_signal_tb;
    logic         mux_imm_signal_tb;
    logic mux_writedata_register_tb;
    logic               mux_jalr_tb;
    logic              write_mem_tb;
    logic               read_mem_tb;
    logic          write_register_tb; 

  
    control_signal dut (
        .instruction            (instruction_tb),
        .comparison             (comparison_tb),
  
        .mux_pc_signal          (mux_pc_signal_tb),
        .mux_imm_signal         (mux_imm_signal_tb),
        .mux_writedata_register (mux_writedata_register_tb),
        .mux_jalr               (mux_jalr_tb),
        .write_mem              (write_mem_tb),
        .read_mem               (read_mem_tb),
        .write_register         (write_register_tb)
    );

    initial begin
        $dumpfile("control_signal_tb.vcd");
        $dumpvars(0, control_signal_tb);  

        $monitor("Time: %d, Mux Pc_signal: %b, Mux Imm signal: %b, Mux Write register: %b, Mux Jalr: %b, Write mem: %b, Read mem: %b, Write register: %b", $time,
                mux_pc_signal_tb, mux_imm_signal_tb, mux_writedata_register_tb, mux_jalr_tb, write_mem_tb, read_mem_tb, write_register_tb);
        instruction_tb = 32'b0000000_00110_00101_000_00100_0110011; //add x4, x5, x6 
        comparison_tb  = 0; 
        #10;
        instruction_tb = 32'b000000001010_00101_000_00100_0010011; //addi x4, x5, 10 
        comparison_tb  = 0; 
        #10;
        instruction_tb = 32'b000000001000_00101_010_00100_0000011; //lw x4, 8(x5) -----> MEM[x5+8] 
        comparison_tb  = 0; 
        #10;
        instruction_tb = 32'b0000000_00110_00101_010_01100_0100011; //sw x6, 12(x5) 
        comparison_tb  = 0; 
        #10;
        //No son iguales
        instruction_tb = 32'b0000000_00110_00101_000_00010_1100011; //beq x5, x6, 16 
        comparison_tb  = 0; 
        #10;
        //Son iguales
        instruction_tb = 32'b0000000_00110_00101_000_00010_1100011; //beq x5, x6, 16 
        comparison_tb  = 1; 
        #10;
        instruction_tb = 32'b00000000000010101011_00100_0110111; //lui x4, 0x000AB
        comparison_tb  = 0; 
        #10;
        instruction_tb = 32'b000000000010_00000000_00001_1101111; //jal x1, 32 
        comparison_tb  = 0; 
        #10;

        $finish;
    end

endmodule