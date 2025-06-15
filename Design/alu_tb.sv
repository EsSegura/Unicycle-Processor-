`timescale 1ns/1ps

module alu_tb;
    parameter WIDTH = 32;
    

    logic [WIDTH-1:0] rs1;
    logic [WIDTH-1:0] rs2;
    logic [WIDTH-1:0] pc;
    logic [2:0]  func3;
    logic [6:0]  func7;
    logic [6:0]  opcode;
    

    logic [WIDTH-1:0] alu_result;
    logic [WIDTH-1:0] pc_plus_4;
    logic [WIDTH-1:0] jump_target;
    logic zero;
    logic branch_taken;
    

    alu #(WIDTH) dut (
        .rs1(rs1),
        .rs2(rs2),
        .pc(pc),
        .func3(func3),
        .func7(func7),
        .opcode(opcode),
        .alu_result(alu_result),
        .pc_plus_4(pc_plus_4),
        .jump_target(jump_target),
        .zero(zero),
        .branch_taken(branch_taken)
    );
    

    localparam ALI_OP    = 7'b0010011;
    localparam AL_OP     = 7'b0110011;
    localparam MEM_WR_OP = 7'b0100011;
    localparam MEM_RD_OP = 7'b0000011;
    localparam BR_OP     = 7'b1100011;
    localparam JALR      = 7'b1100111;
    localparam LUI       = 7'b0110111;
    
    integer error_count = 0;
    
    task check_result;
        input [WIDTH-1:0] expected;
        input [WIDTH-1:0] actual;
        input string test_name;
        begin
            if (actual !== expected) begin
                $display("[ERROR] %s: Expected 0x%h, Got 0x%h", test_name, expected, actual);
                error_count = error_count + 1;
            end
            else begin
                $display("[PASS] %s: 0x%h", test_name, actual);
            end
        end
    endtask
    
    initial begin
        $display("Starting ALU testbench...");
        pc = 32'h00001000;  
        
        // Test 1: ADD (Register)
        opcode = AL_OP;
        func3 = 3'b000;
        func7 = 7'b0000000;
        rs1 = 32'h00000005;
        rs2 = 32'h00000003;
        #10;
        check_result(32'h00000008, alu_result, "ADD 5+3");
        
        // Test 2: SUB (Register)
        func7 = 7'b0100000;
        rs1 = 32'h0000000A;
        rs2 = 32'h00000004;
        #10;
        check_result(32'h00000006, alu_result, "SUB 10-4");
        
        // Test 3: ADDI (Immediate)
        opcode = ALI_OP;
        func3 = 3'b000;
        rs1 = 32'h00000005;
        rs2 = 32'h00000005;
        #10;
        check_result(32'h0000000A, alu_result, "ADDI 5+5");
        
        // Test 4: SLTI (Signed comparison)
        func3 = 3'b010;
        rs1 = 32'hFFFFFFF0;  // -16
        rs2 = 32'h00000005;  // +5
        #10;
        check_result(32'h00000001, alu_result, "SLTI -16<5");
        
        // Test 5: SRAI (Arithmetic shift right)
        func3 = 3'b101;
        func7 = 7'b0100000;
        rs1 = 32'h80000000;  // -2^31
        rs2 = 32'h00000004;  // Shift by 4
        #10;
        check_result(32'hF8000000, alu_result, "SRAI 0x80000000>>4");
        
        // Test 6: JALR
        opcode = JALR;
        pc = 32'h00001000;
        rs1 = 32'h00002000;
        rs2 = 32'h00000008;  // +8
        #10;
        check_result(32'h00001004, alu_result, "JALR return address");
        check_result(32'h00002008, jump_target & ~1, "JALR target address");
        
        // Test 7: BEQ (Branch Equal)
        opcode = BR_OP;
        func3 = 3'b000;
        pc = 32'h00002000;
        rs1 = 32'h0000000A;
        rs2 = 32'h0000000A;  // -10 (sign-extended)
        #10;
        check_result(32'h1, branch_taken, "BEQ 10==10");

        
        // Test 8: LUI
        opcode = LUI;
        rs2 = 32'h12345000;
        #10;
        check_result(32'h12345000, alu_result, "LUI");
        
        // Test 9: XOR (Register)
        opcode = AL_OP;
        func3 = 3'b100;
        rs1 = 32'hA5A5A5A5;
        rs2 = 32'h5A5A5A5A;
        #10;
        check_result(32'hFFFFFFFF, alu_result, "XOR");
        
        // Test 10: Memory address calculation
        opcode = MEM_RD_OP;
        rs1 = 32'h10001000;
        rs2 = 32'h00000FFF;  // +4095
        #10;
        check_result(32'h10001FFF, alu_result, "Load address calculation");
        
        // Summary
        if (error_count == 0) begin
            $display("ALU TESTBENCH PASSED ALL TESTS!");
        end
        else begin
            $display("ALU TESTBENCH FAILED %d TESTS!", error_count);
        end
        
        $finish;
    end
    
    initial begin
        $dumpfile("alu_waveform.vcd");
        $dumpvars(0, alu_tb);
    end
endmodule