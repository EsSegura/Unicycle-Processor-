module mux_2_1
(
    input logic A,
    input logic B,
    input logic sel,

    output logic out
);
    always_comb 
    begin 
        if (sel == 0) out = A;
        else out = B;
    end
    
endmodule