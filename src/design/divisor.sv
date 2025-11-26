module divisor #(
    parameter N = 4
)(
    input  logic [N-1:0] A,   // Dividendo
    input  logic [N-1:0] B,   // Divisor
    output logic [N-1:0] Q,   // Cociente
    output logic [N-1:0] R    // Resto
);

    logic [N:0] R_prev, R_sig, D;
    integer i;

    always_comb begin
        R_prev = '0;
        Q      = '0;

        for (i = N-1; i >= 0; i=i-1) begin
            R_sig = {R_prev[N-1:0], A[i]};
            D = R_sig - B;

            if (D[N] == 1) begin
                Q[i]   = 0;
                R_prev = R_sig;
            end else begin
                Q[i]   = 1;
                R_prev = D;
            end
        end

        R = R_prev[N-1:0];
    end

endmodule
