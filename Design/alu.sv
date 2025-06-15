module alu #(parameter WIDTH=32)(
    input logic [WIDTH-1:0] rs1,
    input logic [WIDTH-1:0] rs2_or_imm,
    input logic [WIDTH-1:0] pc,
    input logic [2:0] func3,
    input logic [6:0] func7,
    input logic [6:0] opcode,

    output logic [WIDTH-1:0] alu_result,
    output logic [WIDTH-1:0] pc_plus_4,
    output logic [WIDTH-1:0] jump_target,
    output logic zero,
    output logic branch_taken
);

    // Opcodes (RV32I)
    localparam ALI_OP    = 7'b0010011;
    localparam AL_OP     = 7'b0110011;
    localparam MEM_WR_OP = 7'b0100011;
    localparam MEM_RD_OP = 7'b0000011;
    localparam BR_OP     = 7'b1100011;
    localparam JALR      = 7'b1100111;
    localparam LUI       = 7'b0110111;

    always_comb begin
        // Default values
        alu_result = '0;
        pc_plus_4 = pc + 4;
        jump_target = '0;
        branch_taken = 1'b0;

        case (opcode)
            ALI_OP: begin  // ALU Immediate operations
                case (func3)
                    3'b000: alu_result = $signed(rs1) + $signed(rs2_or_imm);  // ADDI
                    3'b001: alu_result = rs1 << rs2_or_imm[4:0];               // SLLI
                    3'b010: alu_result = ($signed(rs1) < $signed(rs2_or_imm)); // SLTI
                    3'b011: alu_result = (rs1 < rs2_or_imm);                   // SLTIU
                    3'b100: alu_result = rs1 ^ rs2_or_imm;                     // XORI
                    3'b101: begin
                        if (func7[5])  // SRAI
                            alu_result = $signed(rs1) >>> rs2_or_imm[4:0];
                        else           // SRLI
                            alu_result = rs1 >> rs2_or_imm[4:0];
                    end
                    3'b110: alu_result = rs1 | rs2_or_imm;                     // ORI
                    3'b111: alu_result = rs1 & rs2_or_imm;                     // ANDI
                endcase
            end

            AL_OP: begin  // Register-Register operations
                case (func3)
                    3'b000: begin
                        if (func7[5])  // SUB
                            alu_result = $signed(rs1) - $signed(rs2_or_imm);
                        else           // ADD
                            alu_result = $signed(rs1) + $signed(rs2_or_imm);
                    end
                    3'b001: alu_result = rs1 << rs2_or_imm[4:0];               // SLL
                    3'b010: alu_result = ($signed(rs1) < $signed(rs2_or_imm)); // SLT
                    3'b011: alu_result = (rs1 < rs2_or_imm);                   // SLTU
                    3'b100: alu_result = rs1 ^ rs2_or_imm;                     // XOR
                    3'b101: begin
                        if (func7[5])  // SRA
                            alu_result = $signed(rs1) >>> rs2_or_imm[4:0];
                        else           // SRL
                            alu_result = rs1 >> rs2_or_imm[4:0];
                    end
                    3'b110: alu_result = rs1 | rs2_or_imm;                     // OR
                    3'b111: alu_result = rs1 & rs2_or_imm;                     // AND
                endcase
            end

            MEM_WR_OP, MEM_RD_OP: begin  // Memory operations
                alu_result = $signed(rs1) + $signed(rs2_or_imm);
            end

            BR_OP: begin  // Branch operations
                jump_target = pc + $signed(rs2_or_imm);
                case (func3)
                    3'b000: branch_taken = (rs1 == rs2_or_imm);                // BEQ
                    3'b001: branch_taken = (rs1 != rs2_or_imm);                // BNE
                    3'b100: branch_taken = ($signed(rs1) < $signed(rs2_or_imm)); // BLT
                    3'b101: branch_taken = ($signed(rs1) >= $signed(rs2_or_imm)); // BGE
                    3'b110: branch_taken = (rs1 < rs2_or_imm);                  // BLTU
                    3'b111: branch_taken = (rs1 >= rs2_or_imm);                 // BGEU
                endcase
            end

            JALR: begin
                alu_result = pc + 4;
                jump_target = ($signed(rs1) + $signed(rs2_or_imm)) & ~1;
            end

            LUI: begin
                alu_result = rs2_or_imm;
            end
        endcase
    end

    assign zero = (alu_result == '0);
endmodule
