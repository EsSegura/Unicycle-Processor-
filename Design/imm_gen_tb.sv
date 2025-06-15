`timescale 1ns/1ps

module imm_gen_tb;

    reg [31:0] instr;
    wire [31:0] data_out;

    imm_gen uut (
        .instr(instr),
        .data_out(data_out)
    );
    

    initial begin
        $dumpfile("imm_gen_waves.vcd");
        $dumpvars(0, imm_gen_tb);
    end

    initial begin
        $display("\n=== Iniciando Testbench para imm_gen ===");
        

        // Test 1: I-type (ADDI) - Inmediato positivo
        instr = 32'h00A10113; // ADDI x2, x2, 10 (imm=10)
        #10;
        $display("I-type (positivo): Esperado 0x0000000A, Obtenido 0x%h", data_out);
        

        // Test 2: I-type (ADDI) - Inmediato negativo
        instr = 32'hFF618113; // ADDI x2, x3, -10 (imm=-10)
        #10;
        $display("I-type (negativo): Esperado 0xFFFFFFF6, Obtenido 0x%h", data_out);
        

        // Test 3: S-type (SW) - Inmediato positivo
        instr = 32'h00A32223; // SW x10, 4(x6) (imm=4)
        #10;
        $display("S-type (positivo): Esperado 0x00000004, Obtenido 0x%h", data_out);

        // Test 4: B-type (BEQ) - Inmediato negativo
        instr = 32'hFE209EE3; // BEQ x1, x2, -20 (imm=-20)
        #10;
        $display("B-type (negativo): Esperado 0xFFFFFFEC, Obtenido 0x%h", data_out);

        // Test 5: J-type (JAL) - Inmediato grande
        instr = 32'h012000EF; // JAL x1, 0x120 (imm=0x120)
        #10;
        $display("J-type (grande): Esperado 0x00000120, Obtenido 0x%h", data_out);

        // Test 6: U-type (LUI)
        instr = 32'h12345037; // LUI x0, 0x12345 (imm=0x12345000)
        #10;
        $display("U-type (LUI): Esperado 0x12345000, Obtenido 0x%h", data_out);
  
        // Test 7: Shift (SLLI) - shamt=5
        instr = 32'h00551513; // SLLI x10, x10, 5 (shamt=5)
        #10;
        $display("Shift (shamt=5): Esperado 0x00000005, Obtenido 0x%h", data_out);
        
        $finish;
    end
endmodule