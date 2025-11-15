`timescale 1ns / 1ps

module mult_with_no_sm_tb;

    parameter N = 8;

    logic clk, rst, start;
    logic signed [N-1:0] a, b;
    logic signed [2*N-1:0] y;
    logic done;

    mult_with_no_sm #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .y(y),
        .done(done)
    );

    // Reloj 10ns periodo
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        a = 0;
        b = 0;

        #10 rst = 0;

        run_test(9, 9);      // Esperado: 81
        run_test(-7, 6);     // Esperado: -42
        run_test(-5, -5);    // Esperado: 25
        run_test(10, -3);    // Esperado: -30
        run_test(0, 15);     // Esperado: 0

        $finish;
    end

    task run_test(input signed [N-1:0] op1, op2);
        begin
            a = op1;
            b = op2;
            start = 1;
            @(posedge clk);
            start = 0;

            // Esperar que done se active (multiplicación terminada)
            wait(done);

            // Esperar que done se desactive (volver a IDLE)
            wait(!done);

            // Esperar 1 ciclo de reloj extra para estabilidad
            @(posedge clk);

            $display("Resultado: %0d * %0d = %0d", op1, op2, y);

            #10; // Pequeña pausa para claridad
        end
    endtask

endmodule




