`timescale 1ns/1ps

module teclado_decimal_input_tb();

    logic clk;
    logic rst;
    logic key_pressed;
    logic [3:0] key_value;
    logic [10:0] decimal_out1;
    logic [10:0] decimal_out2;
    logic listo;
    logic [11:0] suma_out;

    // Instancia del módulo
    teclado_decimal_input dut (
        .clk(clk),
        .rst(rst),
        .key_pressed(key_pressed),
        .key_value(key_value),
        .decimal_out1(decimal_out1),
        .decimal_out2(decimal_out2),
        .listo(listo),
        .suma_out(suma_out)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Tarea para simular la pulsación de una tecla
    task press_key(input [3:0] val);
        begin
            key_value = val;
            key_pressed = 1;
            #10; // Un ciclo de reloj
            key_pressed = 0;
            #10;
        end
    endtask

    initial begin
        $display("---- Inicio del testbench ----");
        // Inicialización
        clk = 0;
        rst = 0;
        key_pressed = 0;
        key_value = 0;

        #20;
        rst = 1;  // Liberar reset

        // Ingresar "1", luego "2" → formar 12
        press_key(4'd1);
        press_key(4'd0);
        press_key(4'd0);
        // Confirmar con 'A' (0xA)
        press_key(4'hA);

        // Ingresar "3", luego "4" → formar 34
        press_key(4'd1);
        press_key(4'd0);
        // Confirmar con 'A' (0xA)
        press_key(4'hA);

        // Esperar y verificar salida
        #20;

        $display("Decimal 1: %0d", decimal_out1); // Esperado: 12
        $display("Decimal 2: %0d", decimal_out2); // Esperado: 34
        $display("Suma      : %0d", suma_out);     // Esperado: 46
        $display("Listo     : %0b", listo);        // Esperado: 1 en ese ciclo

        // Esperar algunos ciclos y luego terminar
        #50;
        $finish;
    end

    initial begin
        $dumpfile("teclado_decimal_input_tb.vcd");  // For waveform viewing
        $dumpvars(0, teclado_decimal_input_tb);
    end

endmodule