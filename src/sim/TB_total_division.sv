`timescale 1ns/1ps
`define SIMULATION

module TB_total_division;

    logic clk;
    logic rst;

    // Entradas para simular teclado
    logic [3:0] filas;

    // Bypass del scanner (columnas controladas desde TB)
    logic [3:0] columnas_sim;

    // Señales internas del diseño
    wire [7:0] A_dec, B_dec;
    wire listo, showA, showB, show_mult, multi;
    wire [15:0] suma;
    wire [15:0] cociente;
    wire [15:0] residuo;

    // Instanciar el diseño completo
    module_top_keyboard DUT (
        .clk(clk),
        .reset(rst),
        .filas(filas),
        .columnas(columnas_sim),   // BYPASS DIRECTO
        .A_dec(A_dec),
        .B_dec(B_dec),
        .listo(listo),
        .showA(showA),
        .showB(showB),
        .show_mult(show_mult),
        .multi(multi),
        .suma(suma),
        .cociente(cociente),
        .residuo(residuo)
    );

    // Generar reloj
    initial clk = 0;
    always #10 clk = ~clk;     // 50 MHz aprox.

    // ========== TASKS PARA SIMULAR TECLAS ==========

    task press_key(input logic [3:0] col, input logic [3:0] row);
    begin
        columnas_sim = col;
        filas = row;
        #30000;          // Tiempo presionada
        filas = 4'b1111; // Soltar
        #15000;          // Tiempo entre teclas
    end
    endtask

    // Teclas por dígitos
    task send_digit(input int d);
    begin
        case (d)
            0: press_key(4'b0010, 4'b0001);
            1: press_key(4'b0001, 4'b1000);
            2: press_key(4'b0010, 4'b1000);
            3: press_key(4'b0100, 4'b1000);
            4: press_key(4'b0001, 4'b0100);
            5: press_key(4'b0010, 4'b0100);
            6: press_key(4'b0100, 4'b0100);
            7: press_key(4'b0001, 4'b0010);
            8: press_key(4'b0010, 4'b0010);
            9: press_key(4'b0100, 4'b0010);
        endcase
    end
    endtask

    // Tecla A
    task send_A();
        press_key(4'b1000, 4'b1000);
    endtask

    // Tecla D = operación división
    task send_D();
        press_key(4'b1000, 4'b0001);
    endtask


    // =====================================================
    //              TESTCASE GENERAL
    // =====================================================
    task run_test(input int n1, input int n2);
        int d0, d1;
    begin
        $display("\n==============================");
        $display("     TEST: %0d / %0d", n1, n2);
        $display("==============================\n");

        // Ingresar primer número
        foreach( {int x;} ) begin end // remover warnings

        d1 = n1;
        if (d1 >= 100) begin send_digit(d1/100); d1 %= 100; end
        if (d1 >= 10) begin send_digit(d1/10); d1 %= 10; end
        send_digit(d1);
        send_A();

        // Ingresar segundo número
        d2 = n2;
        if (d2 >= 100) begin send_digit(d2/100); d2 %= 100; end
        if (d2 >= 10) begin send_digit(d2/10); d2 %= 10; end
        send_digit(d2);
        send_A();

        // Ejecutar división
        send_D();

        #200000;

        $display(" A ingresado = %0d", A_dec);
        $display(" B ingresado = %0d", B_dec);
        $display(" Cociente    = %0d", cociente);
        $display(" Residuo     = %0d", residuo);
        $display("----------------------------------\n");
    end
    endtask


    // =====================================================
    //              SECUENCIA PRINCIPAL
    // =====================================================
    initial begin
        filas = 4'b1111;
        columnas_sim = 4'b1111;

        rst = 0;
        #200000;
        rst = 1;

        $display("\n=====================================");
        $display("   SIMULACIÓN TOTAL DEL SISTEMA");
        $display("=====================================\n");

        // Tests pedidos
        run_test(100, 5);
        run_test(44, 7);
        run_test(202, 9);

        $display("\nFIN DE LA SIMULACION.");
        $finish;
    end

endmodule
