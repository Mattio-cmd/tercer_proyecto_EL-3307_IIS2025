`timescale 1ns / 1ps

module clock_test_tb; //testbench del divisor de frecuencia

    logic clk;
    logic n_reset;
    logic pulse_out;

    freq_divider #(
        .INPUT_FREQ(27_000_000),
        .OUTPUT_FREQ(1_000)
    ) uut (
        .clk(clk),
        .n_reset(n_reset),
        .pulse_out(pulse_out)
    );

    // Reloj de 27 MHz (37 ns período)
    initial begin
        clk = 0;
        forever #18.5 clk = ~clk;
    end

    // Reset y simulación
    initial begin

        
        n_reset = 0;  // Reset activo
        #100 n_reset = 1;  // Desactiva reset
        
        // Verifica DIVIDER
        $display("DIVIDER = %d", uut.DIVIDER);
        
        // Espera 3 pulsos (3 ms)
        #3_000_000;
        $display("Simulación completada");
        $finish;

    end

    initial begin
    $monitor("Time = %0t ns: counter = %d, pulse_out = %b", 
                 $time, uut.counter, pulse_out);
    end

    initial begin
    $dumpfile("clock_test_tb.vcd");  // For waveform viewing
    $dumpvars(0, clock_test_tb);
    end



endmodule

