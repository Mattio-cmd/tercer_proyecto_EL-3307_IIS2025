// tb_divisor.sv
`timescale 1ns/1ps
module tb_divisor;

    localparam N = 4;

    // Señales conectadas al módulo top
    logic [N-1:0] A, B;
    logic [N-1:0] Q, R;

    // Instancia del top
    top uut (
        .A(A),
        .B(B),
        .Q(Q),
        .R(R)
    );

    initial begin
        $dumpfile("tb_divisor.vcd");
        $dumpvars(0, tb_divisor);

        $display("=-------------------------------------------------=");
        $display("  SIMULACIÓN DEL DIVISOR (N=%0d bits)", N);
        $display("=-------------------------------------------------=");

        // --- CASO 1: 13 / 4 ---
        A = 13; B = 4; #1;
        $display("13 / 4 → Q=%0d R=%0d  [Esperado: Q=3 R=1]", Q, R);
        if (Q !== 3 || R !== 1) $error("FALLO: 13/4");

        // --- CASO 2: 10 / 3 ---
        A = 10; B = 3; #1;
        $display("10 / 3 → Q=%0d R=%0d  [Esperado: Q=3 R=1]", Q, R);
        if (Q !== 3 || R !== 1) $error("FALLO: 10/3");

        $display("--------------------------------------------------=");
        $display("  SIMULACIÓN COMPLETADA");
        $display("---------------------------------------------------=");
        $finish;
    end

endmodule