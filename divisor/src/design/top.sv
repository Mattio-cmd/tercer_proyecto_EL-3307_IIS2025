module top(
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] Q,
    output logic [3:0] R
);

    divisor #(.N(4)) divisor_ut (
        .A(A),
        .B(B),
        .Q(Q),
        .R(R)
    );

endmodule
