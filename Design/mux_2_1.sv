module mux_2_1
(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic sel,

    output logic [31:0]out
);
    always_comb 
    begin 
        if (sel == 0) out = A;
        else out = B;
    end
    
endmodule