`timescale 1ps/1ps

module fsm_control_tb;

    // Entradas
    reg clk_tb;
    reg rst_tb;
    reg BW_tb;
    reg BR_tb;
    reg PW_tb;
    reg PR_tb;
    reg S_tb;

    // Salida
    wire [1:0] status_tb;

    // Instancia del módulo
    control dut (
        .clk(clk_tb),
        .rst(rst_tb),
        .BW(BW_tb),
        .BR(BR_tb),
        .PW(PW_tb),
        .PR(PR_tb),
        .S(S_tb),
        .status(status_tb)
    );

    // Reloj
    always begin
        #5 clk_tb = ~clk_tb;
    end

    // Estímulos
    initial begin
        $dumpfile("control.vcd");
        $dumpvars(0, fsm_control_tb);

        clk_tb = 0;
        rst_tb = 1; BW_tb = 0; BR_tb = 0; PR_tb = 0; PW_tb = 0; S_tb = 0;
        #10;

        rst_tb = 0; BW_tb = 1; BR_tb = 0; PR_tb = 0; PW_tb = 0; S_tb = 0;
        #20;

        BW_tb = 0; BR_tb = 0; PR_tb = 0; PW_tb = 1; S_tb = 0;
        #20;

        BW_tb = 0; BR_tb = 1; PR_tb = 0; PW_tb = 0; S_tb = 0;
        #20;

        BW_tb = 0; BR_tb = 0; PR_tb = 1; PW_tb = 0; S_tb = 1;
        #100;

        $finish;
    end

endmodule
