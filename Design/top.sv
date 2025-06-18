`include "mux_2_1.sv"
`include "adder.sv"
`include "imm_gen.sv"
`include "alu.sv"   
`include "data_memory.sv"
`include "control_signal.sv"    
`include "register_file.sv"
`include "register.sv"
`include "inst_memory.sv"

module top #(parameter WIDTH=32, parameter DEPTH=20) (
    input  logic clk,
    input  logic rst,
    output logic [WIDTH-1:0] pc_out
);

    // Signals
    wire [WIDTH-1:0] pc_actual;
    wire [WIDTH-1:0] next_pc;
    wire [WIDTH-1:0] pc_plus_4;
    wire [WIDTH-1:0] pc_plus_imm;
    wire [WIDTH-1:0] instr;
    wire [WIDTH-1:0] imm_data;
    wire [WIDTH-1:0] alu_result;
    wire [WIDTH-1:0] data_mem_out;
    wire [WIDTH-1:0] reg_data_out;
    wire [WIDTH-1:0] inst_out;
    wire  [WIDTH-1:0] rs1_data;
    wire  [WIDTH-1:0] rs2_data;
    wire  [WIDTH-1:0] rs2_data_to_alu;
    wire  [WIDTH-1:0] rs3_data; 
    wire  [WIDTH-1:0] write_data;

    // Control signals
    wire mux_pc_signal;
    wire mux_imm_signal;
    wire mux_writedata_register;
    wire mux_jalr_signal;
    wire write_mem;
    wire read_mem;
    wire write_register_signal;
    wire zero;
    wire branch_taken;
    wire one_byte; 
    wire two_bytes; 
    wire four_bytes;

    assign pc_out = pc_actual;

    // Instantiate modules
    //Instruction Fetch
    register #(WIDTH) pc_register (
        .clk(clk),
        .rst(rst),
        .write(1'b1), // Always write to PC
        .data_in(next_pc),
        .data_out(pc_actual)
    );

    inst_mem inst_memory (
    .clk(clk),
    .rst(rst),
    .addr(pc_actual[31:2]),  // <<-- Divide la dirección entre 4 (word-aligned)
    .data_in(32'd0),
    .wr(1'b0),
    .rd(1'b1),
    .data_out(instr)
);

    mux_2_1 mux_pc (
        .A(pc_plus_4), // Default to next instruction
        .B(inst_out), // Jump targe //inst_out
        .sel(mux_pc_signal),
        .out(next_pc)
    );

    //Despues del pc
    adder #(WIDTH) adder_unit_1 (
        .A(pc_actual),
        .B(32'd4),
        .result(pc_plus_4)
    );


    //Instruction Decode
    reg_file reg_file (
        .clk(clk),
        .rst(rst),
        .write_data(write_data),
        .write_register(instr[11:7]), // rd field
        .write(write_register_signal),
        .read_register_1(instr[19:15]),
        .read_register_2(instr[24:20]),
        .read(1'b1),    
        .read_data_1(rs1_data),
        .read_data_2(rs2_data)  
    );

    imm_gen #(WIDTH) imm_generator (
        .instr(instr),
        .data_out(imm_data)
    );

    //Execution
    mux_2_1 mux_prealu(
        .A(rs2_data), // Default to next instruction
        .B(imm_data), // Jump targe
        .sel(mux_imm_signal),
        .out(rs2_data_to_alu)//entrada alu
    );
    mux_2_1 mux_jalr (
        .A(pc_plus_imm), // Default to next instruction
        .B(rs3_data), // Jump target
        .sel(mux_jalr_signal),
        .out(inst_out) 
    );
    //Despues del pc y adder
    adder #(WIDTH) adder_unit_2 (
        .A(pc_actual),
        .B(imm_data),
        .result(pc_plus_imm) // Jump target
    );
    alu #(WIDTH) alu_unit (
        .rs1(rs1_data),
        .rs2(rs2_data_to_alu),
        .pc(pc_actual),
        .func3(instr[14:12]),
        .func7(instr[31:25]),
        .opcode(instr[6:0]),
        .alu_result(alu_result),
        .jump_target(rs3_data),
        .zero(zero),
        .branch_taken(branch_taken)
    );

    //Memory
    data_mem  data_memory_unit (
        .clk(clk),
        .rst(rst),
        .data_in(rs2_data),
        .one_byte(one_byte),
        .two_bytes(two_byte),
        .four_bytes(four_bytes),
        .addr(alu_result[DEPTH-1:0]),
        .wr(write_mem),
        .rd(read_mem),
        .data_out(data_mem_out)
    );

    //Write back
    mux_2_1 mux_postalu(
        .A(alu_result), // Default to next instruction
        .B(data_mem_out), // Jump targe
        .sel(mux_writedata_register),
        .out(write_data)
    );
    
    //Control
    control_signal control_unit (
        .instruction(instr),
        .comparison(branch_taken), // Example comparison signal
        .mux_pc_signal(mux_pc_signal),
        .mux_imm_signal(mux_imm_signal),
        .mux_writedata_register(mux_writedata_register),
        .mux_jalr(mux_jalr_signal),
        .write_mem(write_mem),
        .read_mem(read_mem),
        .one_byte(one_byte),
        .two_bytes(two_bytes),
        .four_byte(four_bytes),
        .write_register(write_register_signal)
    );

endmodule

    