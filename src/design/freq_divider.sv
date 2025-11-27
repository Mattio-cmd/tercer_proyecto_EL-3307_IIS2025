//`ifndef SYNTHESIS
    //`define SIMULATION
//`endif
module freq_divider (
    input  logic clk,
    input  logic rst,
    output logic slow_clk
);

`ifdef SIMULATION
    // Clock rápido para TB: alterna cada 500 ns
    always_ff @(posedge clk) begin
        if (!rst)
            slow_clk <= 0;
        else
            slow_clk <= ~slow_clk;
    end

`else
    // Versión real para FPGA
    logic [15:0] counter;

    always_ff @(posedge clk) begin
        if (!rst) begin
            counter  <= 0;
            slow_clk <= 0;
        end else begin
            if (counter == 27000) begin
                slow_clk <= ~slow_clk;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
`endif

endmodule
