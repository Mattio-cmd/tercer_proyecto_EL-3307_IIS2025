// tb_divisor.sv
`timescale 1ns/1ps
module tb_divisor;

    // Parámetros
    localparam N = 4;
    localparam PERIOD = 10; // Periodo de espera para la simulación

    // Señales internas que se conectarán al módulo 'top'
    logic [N-1:0] A; // Dividendo
    logic [N-1:0] B; // Divisor
    logic [N-1:0] Q; // Cociente (Resultado)
    logic [N-1:0] R; // Resto

    // Variables para verificación
    logic [N-1:0] expected_Q;
    logic [N-1:0] expected_R;

    // Instanciación del módulo a probar. Este se conecta el módulo top, que a su vez instancia el divisor
    top uut_top (
        .A(A),
        .B(B),
        .Q(Q),
        .R(R)
    );


    // Bloque inicial para la simulación
    initial begin

        // Configuración de volcado VCD (para visualización en GTKWave)
        $dumpfile("tb_divisor.vcd");
        $dumpvars(0, tb_divisor);
        $display("---------------------------------------------------------");
        $display("Iniciando la simulación del módulo divisor (N=%0d bits)...", N);
        $display("---------------------------------------------------------");

        // Inicialización de entradas
        A = 0;
        B = 0;
        #(PERIOD); // Espera inicial

        // ----------------------------------------------------------------
        // CASO DE PRUEBA 1
        // Usando 13 / 4 = 3 (Cociente) | 1 (Resto)
        // ----------------------------------------------------------------
        A = 13; // 1101
        B = 4;  // 0100
        expected_Q = 3;
        expected_R = 1;

        #(PERIOD); // Esperar a que la lógica combinacional se asiente

        $display("Prueba 1: %0d / %0d", A, B);
        $display("  Esperado: Q=%0d, R=%0d", expected_Q, expected_R);
        $display("  Obtenido: Q=%0d, R=%0d", Q, R);

        if (Q == expected_Q && R == expected_R) begin
            $display("  RESULTADO: Éxito (Success)");
        end else begin
            $display("  RESULTADO: Fallo (FAILURE) - Valores incorrectos");
            $fatal(1, "La prueba 1 falló: 13/4");
        end
        $display("---");


        // ----------------------------------------------------------------
        // Finalización
        // ----------------------------------------------------------------
        $display("---------------------------------------------------------");
        $display("Simulación completa. Resultados guardados en TB_divisor.vcd");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule
