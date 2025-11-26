module tb_divisor_secuencial;

parameter N = 8;

logic clk;
logic rst;
logic valid;
logic [N-1:0] A;
logic [N-1:0] B;
logic [N-1:0] Q;
logic [N-1:0] R;
logic done;
logic error;

// Instancia del DUT
divisor_secuencial #(.N(N)) dut (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .A(A),
    .B(B),
    .Q(Q),
    .R(R),
    .done(done),
    .error(error)
);

// Generación del reloj (27 MHz)
initial begin
    clk = 0;
    forever #18.5 clk = ~clk;  // ~27 MHz
end

// Variables para verificación
integer expected_Q, expected_R;
integer test_count = 0;
integer pass_count = 0;

// Tarea para realizar una división
task test_division(input [N-1:0] dividend, input [N-1:0] divisor);
    begin
        test_count++;

        // Calcular resultado esperado
        if (divisor == 0) begin
            expected_Q = 0;
            expected_R = dividend;
        end
        else begin
            expected_Q = dividend / divisor;
            expected_R = dividend % divisor;
        end

        // Aplicar entradas
        A = dividend;
        B = divisor;
        valid = 1'b1;
        @(posedge clk);
        valid = 1'b0;

        // Esperar done
        wait(done || error);
        @(posedge clk);

        // Verificar resultados
        if (divisor == 0) begin
            if (error) begin
                $display("[PASS] Test %0d: %0d / %0d -> ERROR (división por cero)",
                         test_count, dividend, divisor);
                pass_count++;
            end
            else begin
                $display("[FAIL] Test %0d: %0d / %0d -> Esperaba error",
                         test_count, dividend, divisor);
            end
        end
        else begin
            if (Q == expected_Q && R == expected_R) begin
                $display("[PASS] Test %0d: %0d / %0d = %0d, R=%0d",
                         test_count, dividend, divisor, Q, R);
                pass_count++;
            end
            else begin
                $display("[FAIL] Test %0d: %0d / %0d = %0d, R=%0d (Esperado: Q=%0d, R=%0d)",
                         test_count, dividend, divisor, Q, R, expected_Q, expected_R);
            end
        end

        // Esperar algunos ciclos antes del siguiente test
        repeat(3) @(posedge clk);
    end
endtask

// Secuencia de pruebas
initial begin
    $dumpfile("tb_divisor_secuencial.vcd");
    $dumpvars(0, tb_divisor_secuencial);

    // Reset
    rst = 0;
    valid = 0;
    A = 0;
    B = 0;
    repeat(3) @(posedge clk);
    rst = 1;
    repeat(2) @(posedge clk);

    $display("\n=== Iniciando pruebas del divisor secuencial ===\n");

    // Casos de prueba básicos
    test_division(8'd100, 8'd10);   // 100 / 10 = 10, R=0
    test_division(8'd127, 8'd8);    // 127 / 8 = 15, R=7
    test_division(8'd255, 8'd16);   // 255 / 16 = 15, R=15
    test_division(8'd50, 8'd7);     // 50 / 7 = 7, R=1
    test_division(8'd1, 8'd2);      // 1 / 2 = 0, R=1

    // Casos especiales
    test_division(8'd0, 8'd5);      // 0 / 5 = 0, R=0
    test_division(8'd10, 8'd1);     // 10 / 1 = 10, R=0
    test_division(8'd99, 8'd99);    // 99 / 99 = 1, R=0
    test_division(8'd50, 8'd100);   // 50 / 100 = 0, R=50

    // División por cero
    test_division(8'd100, 8'd0);    // Debe generar error

    // Casos límite
    test_division(8'd255, 8'd1);    // 255 / 1 = 255, R=0
    test_division(8'd255, 8'd255);  // 255 / 255 = 1, R=0

    // Resultados finales
    $display("\n=== Resumen de pruebas ===");
    $display("Total: %0d | Aprobadas: %0d | Fallidas: %0d",
             test_count, pass_count, test_count - pass_count);

    if (pass_count == test_count)
        $display("\n¡Todas las pruebas pasaron! ✓\n");
    else
        $display("\nAlgunas pruebas fallaron ✗\n");

    $finish;
end

// Timeout de seguridad
initial begin
    #100000;
    $display("\n[ERROR] Timeout - Simulación terminada forzosamente");
    $finish;
end

endmodule
