`timescale 1 ns / 100 ps

module scanner_tb;

  // Señales
  logic clk;
  logic n_reset;
  logic pulse_out;
  logic [3:0] columnas;

  // Instancia del DUT (Device Under Test)
  scanner uut (
    .clk(clk),
    .n_reset(n_reset),
    .pulse_out(pulse_out),
    .columnas(columnas)
  );

  // Generador de reloj
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock (10ns período)
  end

  // Generador de pulse_out simulado (simula lo que enviaría freq_divider)
  initial begin
    pulse_out = 0;
    forever begin
      #100;  // Cada 100ns genera un pulso
      pulse_out = 1;
      #10;   // Pulso de 10ns de ancho
      pulse_out = 0;
    end
  end

  // Estímulos iniciales
  initial begin
    n_reset = 0;
    #20;
    n_reset = 1;

    // Dejar correr la simulación por un tiempo
    #2000; // Simular 2 microsegundos (suficiente para ver varias rotaciones)

    $finish;
  end

  // Monitor de señales
  initial begin
    $monitor("Time = %0t ns, columnas = %b, col_idx = %0d", $time, columnas, uut.col_idx);
  end

    initial begin
        $dumpfile("scanner_tb.vcd");  // For waveform viewing
        $dumpvars(0, scanner_tb);
    end

endmodule
