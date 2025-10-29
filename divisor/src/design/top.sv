module top;

    localparam N = 4;

    logic [N-1:0] A, B;
    logic [N-1:0] Q, R;

    divisor #(.N(N)) divisor_ut (
        .A(A),
        .B(B),
        .Q(Q),
        .R(R)
    );

    // se supone que en el testbench salga algo como
    // Q = 0110 (6)
    // R = 0001 (1)


endmodule
