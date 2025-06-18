`include "mux_2_1.sv"
`include "adder.sv"
`include "imm_gen.sv"
`include "alu.sv"   
`include "data_memory.sv"
`include "control_signal.sv"    
`include "register_file.sv"
`include "register.sv"
`include "inst_memory.sv"

module top #(parameter WIDTH=32, parameter DEPTH=16) (
    input  logic clk,
    input  logic rst,
    output logic [WIDTH-1:0] pc_out
);

    // Signals
    logic [WIDTH-1:0] pc;
    logic [WIDTH-1:0] instr;
    logic [WIDTH-1:0] imm_data;
    logic [WIDTH-1:0] alu_result;
    logic [WIDTH-1:0] data_mem_out;
    logic [WIDTH-1:0] reg_data_out;

    // Control signals
    logic mux_pc_signal;
    logic mux_imm_signal;
    logic mux_writedata_register;
    logic mux_jalr;
    logic write_mem;
    logic read_mem;
    logic write_register;

    // Instantiate modules
    inst_mem #(WIDTH, DEPTH) inst_memory (
        .clk(clk),
        .rst(rst),
        .addr(pc[DEPTH-1:2]),
        .rd(1'b1),
        .data_out(instr)
    );

    imm_gen #(WIDTH) imm_generator (
        .instr(instr),
        .data_out(imm_data)
    );

    alu #(WIDTH) alu_unit (
        .a(reg_data_out),
        .b(imm_data),
        .alu_control(instr[14:12]),
        .result(alu_result)
    );

    data_memory #(WIDTH, DEPTH) data_memory_unit (
        .clk(clk),
        .rst(rst),
        .data_in(reg_data_out),
        .addr(alu_result[DEPTH-1:2]),
        .wr(write_mem),
        .rd(read_mem),
        .data_out(data_mem_out)
    );

    control_signal control_unit (
        .opcode(instr[6:0]),
        .comparison(alu_result[0]), // Example comparison signal
        .mux_pc_signal(mux_pc_signal),
        .mux_imm_signal(mux_imm_signal),
        .mux_writedata_register(mux_writedata_register),
        .mux_jalr(mux_jalr),
        .write_mem(write_mem),
        .read_mem(read_mem),
        .write_register(write_register)
    );

    register_file #(WIDTH) reg_file (
        .clk(clk),
        .rst(rst),
        .write(write_register),
        .read_addr_a(instr[19:15]),
        .read_addr_b(instr[24:20]),
        .write_addr(instr[11:7]),
        .write_data(mux_writedata_register ? data_mem_out : alu_result),
        .read_data_a(reg_data_out), 
        .read_data_b() // Not used in this example
    );
    register #(WIDTH) pc_register (
        .clk(clk),
        .rst(rst),
        .write(1'b1), // Always write to PC
        .data_in(mux_pc_signal ? alu_result : (pc + 4)),
        .data_out(pc)
    );
    assign pc_out = pc;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0; // Reset PC to 0
        end else begin
            pc <= mux_pc_signal ? alu_result : (pc + 4); // Increment PC or jump
        end
    end 
endmodule
    