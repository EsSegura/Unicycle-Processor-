module imm_gen #(parameter WIDTH=32) (
    input  logic [WIDTH-1:0] instr,
    output logic [WIDTH-1:0] data_out
);


    localparam ALI_OP    = 7'b0010011;
    localparam MEM_WR_OP = 7'b0100011;
    localparam MEM_RD_OP = 7'b0000011;
    localparam BR_OP     = 7'b1100011;
    localparam JALR      = 7'b1100111;
    localparam JAL       = 7'b1101111;
    localparam LUI       = 7'b0110111;

    wire [6:0] opcode = instr[6:0];
    wire [2:0] func3  = instr[14:12];


    wire [31:0] imm_i     = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s     = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b     = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_j     = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [31:0] imm_u     = {instr[31:12], 12'b0};
    wire [31:0] imm_shamt = {27'b0, instr[24:20]};

    always_comb begin
        case(opcode)
            ALI_OP:    data_out = (func3 != 3'b001 && func3 != 3'b101) ? imm_i : imm_shamt;
            MEM_WR_OP: data_out = imm_s;
            MEM_RD_OP: data_out = imm_i;
            BR_OP:     data_out = imm_b;
            JALR:      data_out = imm_i;
            JAL:       data_out = imm_j;
            LUI:       data_out = imm_u;
            default:   data_out = '0;
        endcase
    end
endmodule