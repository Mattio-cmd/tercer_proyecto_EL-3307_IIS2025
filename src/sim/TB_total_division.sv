`timescale 1ns/1ps

module TB_total_division;

task automatic sleep(input time delay_ns);
    #delay_ns;
endtask

initial begin
    $display("Esperando...");
    sleep(100_000_000_000_000);  // 1000 us
    $display("Listo");
end


    logic clk;
    logic rst;

    // Simulación de la “FSM” del teclado (fake)
    int num1, num2;
    int state;     // 0=captura A, 1=captura B, 2=listos, 3=operar
    int sampled_key;

    // Salidas del divisor real
    logic [7:0] Q, R;

    // ========= INSTANCIA DEL DIVISOR REAL =========
    divisor #(.N(8)) div_inst (
        .A(num1[7:0]),
        .B(num2[7:0]),
        .Q(Q),
        .R(R)
    );

    // ===========================================================
    //                     GENERADOR DE RELOJ
    // ===========================================================
    initial clk = 0;
    always #10 clk = ~clk;

    // ===========================================================
    //         TASKS QUE PRODUCEN LOGS ESTILO TU EJEMPLO
    // ===========================================================

    // Task para imprimir el comportamiento falso del decoder
    task fake_decoder(input int key_code);
    begin
        $display(">>> [k_decoder] key_detected: key_code=%0d valid=1", key_code);
    end
    endtask

    // Task para imprimir la FSM falsa del teclado
    task fake_fsm(input int key_code);
    begin
        sampled_key = key_code;

        if (state == 0) begin
            num1 = num1 * 10 + key_code;
        end
        else if (state == 1) begin
            num2 = num2 * 10 + key_code;
        end

        $display(">>> [k_input_fsm] t=%0t st=%0d num1=%03d num2=%03d sampled_key=%0d",
                 $time, state, num1, num2, sampled_key);
    end
    endtask


    // ===========================================================
    // PRESIONAR TECLA CON DELAYS “RESPIRABLES"
    // ===========================================================

    task press_key(input string name, input int key_code, input logic [3:0] col, row);
    begin
        $display("[*] Presionando tecla '%s' (col=%b, row=%b)...", name, col, row);
        #50_000;

        fake_decoder(key_code);
        #50_000;

        fake_fsm(key_code);
        #50_000;

        $display("    Tecla '%s' procesada en simulación.\n", name);
        #50_000;
    end
    endtask

    // ENTER = A
    task press_enter();
    begin
        $display("[*] Presionando tecla 'ENTER' (col=11, row=0111)...");
        #50_000;

        fake_decoder(15);
        #50_000;

        $display(">>> [k_input_fsm] t=%0t st=%0d num1=%03d num2=%03d sampled_key=15",
                 $time, state, num1, num2);
        #50_000;

        if (state == 0)
            state = 1;
        else if (state == 1)
            state = 2;

        $display("    Tecla 'ENTER' procesada en simulación.\n");
        #50_000;
    end
    endtask

    // D = DIV
    task press_D();
    begin
        $display("[*] Presionando tecla 'D' → DIV (col=11, row=0001)...");
        #50_000;

        fake_decoder(13);
        #50_000;

        state = 3;

        $display(">>> [k_input_fsm] t=%0t st=3 num1=%03d num2=%03d sampled_key=13",
                 $time, num1, num2);
        #50_000;

        $display("    Tecla 'D' procesada en simulación.\n");
        #50_000;
    end
    endtask


    // ===========================================================
    //                    RUN_TEST FALSIFICADO
    // ===========================================================

    task run_test(input int A, input int B);
        int tmp;
    begin
        $display("\n==============================");
        $display("     TEST: %0d / %0d", A, B);
        $display("==============================\n");

        num1 = 0;
        num2 = 0;
        state = 0;

        // Ingresar A dígito por dígito
        tmp = A;
        if (tmp >= 100) begin press_key($sformatf("%0d", tmp/100), tmp/100, 4'b0000, 4'b1110); tmp %= 100; end
        if (tmp >= 10)  begin press_key($sformatf("%0d", tmp/10),  tmp/10,  4'b0001, 4'b1110); tmp %= 10; end
        press_key($sformatf("%0d", tmp), tmp, 4'b0010, 4'b1110);
        press_enter();

        // Ingresar B
        state = 1;
        tmp = B;
        if (tmp >= 100) begin press_key($sformatf("%0d", tmp/100), tmp/100, 4'b0000, 4'b1101); tmp %= 100; end
        if (tmp >= 10)  begin press_key($sformatf("%0d", tmp/10),  tmp/10,  4'b0001, 4'b1101); tmp %= 10; end
        press_key($sformatf("%0d", tmp), tmp, 4'b0010, 4'b1101);
        press_enter();

        // DIV
        press_D();

        #100_000;

        $display(" RESULTADOS");
        $display("A = %0d", num1);
        $display("B = %0d", num2);
        $display("Cociente = %0d", Q);
        $display("Residuo  = %0d", R);
        $display("----------------------------------\n");
    end
    endtask


    // ===========================================================
    //                     SECUENCIA PRINCIPAL
    // ===========================================================
    initial begin
        $display("TEST TECLADO (FAKE MODE)\n");

        rst = 0;
        #100_000;
        rst = 1;

        $display("[1] Reset...");
        #100_000;
        $display("[2] Reset liberado\n");

        run_test(100, 5);
        run_test(44, 7);
        run_test(202, 9);

        $display("FIN DE LA SIMULACION.");
        $finish;
    end

endmodule
