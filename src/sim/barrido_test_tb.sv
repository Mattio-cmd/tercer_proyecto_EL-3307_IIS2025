`timescale 1ns / 1ps

module barrido_test_tb; //testbench para hacer el barrido de columnas

// ------------------ Señales de prueba ------------------------
    logic clk;                // Reloj rápido de entrada (27 MHz o 100 MHz)
    logic n_reset;            // Reset activo bajo
    logic [3:0] columnas;     // Columnas barridas
    logic [3:0] leds;         // LEDs para visualizar el barrido
    logic pulse_out;          // Pulso lento generado por el divisor de frecuencia

    // ------------------ Instanciación del módulo barrido_test ------------------------
    barrido_test uut (
        .clk(clk),
        .n_reset(n_reset),
        .columnas(columnas),
        .leds(leds)
    );

    // ------------------ Generación de reloj ------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Genera un reloj de 100 MHz
    end

    // ------------------ Generación de señales de reset ------------------------
    initial begin
        n_reset = 0;           // Inicialmente el reset está activo
        #10 n_reset = 1;       // Desactiva el reset después de 10 ns
    end

    // ------------------ Monitoreo de las señales ------------------------
    initial begin
        $monitor("Time = %0t, columnas = %b, leds = %b, pulse_out = %b", $time, columnas, leds, pulse_out);
    end

    // ------------------ Simulación ------------------------
    initial begin
        // Inicializa los valores
        #20;  // Espera 20 ns para que las señales se estabilicen

        // Finaliza la simulación después de un tiempo
        #1000;
        $finish;
    end

    // ------------------ Dump de señales para visualización en un visor de formas de onda ------------------------
    initial begin
        $dumpfile("barrido_test_tb.vcd");  // Nombre del archivo VCD para la visualización
        $dumpvars(0, barrido_test_tb);     // Dump de todas las señales
    end

endmodule