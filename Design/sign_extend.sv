module sign_extend #(
    parameter IN_WIDTH = 12,
    parameter OUT_WIDTH = 32
)(
    input  logic signed [IN_WIDTH-1:0] imm_in,
    output logic signed [OUT_WIDTH-1:0] imm_out
);
    assign imm_out = imm_in; 
endmodule
