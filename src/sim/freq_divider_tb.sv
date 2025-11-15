`timescale 1 ns / 1 ps

module freq_divider_tb;

 // Señales del testbench
    logic clk;        // Reloj de entrada (27 MHz)
    logic rst;        // Reset
    logic slow_clk;   // Salida del reloj lento (500 Hz)

    // Instancia del divisor de frecuencia
    freq_divider uut (
        .clk(clk),
        .rst(rst),
        .slow_clk(slow_clk)
    );

    // Generación del reloj de 27 MHz (periodo de 37ns)
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;  // 27 MHz = 37ns por ciclo
    end

    // Generación del reset y simulación
    initial begin


        rst = 0;  // Activar reset
        #50 rst = 1;  // Desactivar reset después de 50ns

        // Simulación de 10ms para ver los cambios en slow_clk
       #20;
        $finish;
    end

    // Monitor de salida para ver el comportamiento del reloj lento
    initial begin
        $monitor("Time = %0t, slow_clk = %b", $time, slow_clk);
    end

    initial begin
      $dumpfile("freq_divider_tb.vcd");  // For waveform viewing
      $dumpvars(0, freq_divider_tb);
    end

endmodule
