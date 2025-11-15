`timescale 1ns/1ps

module bin_to_bcd_tb;

    // Entradas y salidas
    logic [11:0] bin_in;
    logic [3:0] bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones;

    // Instancia del módulo bajo prueba
    bin_to_bcd uut (
        .bin_in(bin_in),
        .bcd_thousands(bcd_thousands),
        .bcd_hundreds(bcd_hundreds),
        .bcd_tens(bcd_tens),
        .bcd_ones(bcd_ones)
    );

    // Tarea para imprimir valores
    task print_result(input [11:0] val);
        $display("bin_in = %0d -> BCD = %0d%0d%0d%0d",
            val, bcd_thousands, bcd_hundreds, bcd_tens, bcd_ones);
    endtask

    // Proceso de prueba
    initial begin
        $display("=== Testbench: bin_to_bcd ===");

        // Pruebas básicas
        bin_in = 12'd0; #1; print_result(bin_in);
        bin_in = 12'd5; #1; print_result(bin_in);
        bin_in = 12'd9; #1; print_result(bin_in);
        bin_in = 12'd10; #1; print_result(bin_in);
        bin_in = 12'd15; #1; print_result(bin_in);
        bin_in = 12'd23; #1; print_result(bin_in);
        bin_in = 12'd42; #1; print_result(bin_in);
        bin_in = 12'd99; #1; print_result(bin_in);
        bin_in = 12'd123; #1; print_result(bin_in);
        bin_in = 12'd255; #1; print_result(bin_in);
        bin_in = 12'd512; #1; print_result(bin_in);
        bin_in = 12'd999; #1; print_result(bin_in);
        bin_in = 12'd1023; #1; print_result(bin_in);
        bin_in = 12'd2047; #1; print_result(bin_in); // máximo de 12 bits

        $display("=== Fin del test ===");
        $finish;
    end

    initial begin
        $dumpfile("bin_to_bcd_tb.vcd");  // For waveform viewing
        $dumpvars(0, bin_to_bcd_tb);
    end

endmodule
