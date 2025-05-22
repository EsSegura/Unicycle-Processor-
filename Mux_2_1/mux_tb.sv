`timescale 1ns/1ns

module mux_tb;

    logic A_tb;
    logic B_tb;
    logic sel_tb;
    logic out_tb; 

  
    mux_2_1 dut (
        .A(A_tb),
        .B(B_tb),
        .sel(sel_tb),
        .out(out_tb)
    );

    initial begin
        $dumpfile("mux.vcd");
        $dumpvars(0, mux_tb);  

        A_tb = 0; B_tb = 0; sel_tb = 0; #10;
        A_tb = 0; B_tb = 1; sel_tb = 0; #10;
        A_tb = 0; B_tb = 1; sel_tb = 1; #10;
        A_tb = 1; B_tb = 0; sel_tb = 1; #10;
        A_tb = 1; B_tb = 0; sel_tb = 0; #10;
        A_tb = 0; B_tb = 0; sel_tb = 0; #10;

        $finish;
    end

endmodule
