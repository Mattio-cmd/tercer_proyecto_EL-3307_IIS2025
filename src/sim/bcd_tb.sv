`timescale 1 ns / 100 ps

module bcd_tb;

  // Señales
    // Entradas y salidas
    logic [3:0] bcd;
    logic [6:0] seg;

    // Instanciar el módulo bajo prueba (DUT)
    bcd dut (
        .bcd(bcd),
        .seg(seg)
    );

    // Procedimiento de prueba
    initial begin
        // Encabezado
        $display("BCD | SEGMENTOS");
        $display("----+----------");

        // Prueba de todos los valores posibles (0 a 15)
        for (int i = 0; i < 16; i++) begin
            bcd = i;
            #1; // Espera para evaluación combinacional
            $display(" %2d | %07b", bcd, seg);
        end

        $finish;
    end

    initial begin
    $dumpfile("bcd_tb.vcd");  // For waveform viewing
    $dumpvars(0, bcd_tb);
    end

endmodule
