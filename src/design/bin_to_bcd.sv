module bin_to_bcd (
    input  logic [15:0] bin_in,         // hasta 9999
    output logic [3:0] bcd_thousands,
    output logic [3:0] bcd_hundreds,
    output logic [3:0] bcd_tens,
    output logic [3:0] bcd_ones
);
    logic [15:0] temp;

    always_comb begin
        temp = bin_in;

        // THOUSANDS
        if (temp >= 9000) begin
            bcd_thousands = 4'd9; temp = temp - 9000;
        end else if (temp >= 8000) begin
            bcd_thousands = 4'd8; temp = temp - 8000;
        end else if (temp >= 7000) begin
            bcd_thousands = 4'd7; temp = temp - 7000;
        end else if (temp >= 6000) begin
            bcd_thousands = 4'd6; temp = temp - 6000;
        end else if (temp >= 5000) begin
            bcd_thousands = 4'd5; temp = temp - 5000;
        end else if (temp >= 4000) begin
            bcd_thousands = 4'd4; temp = temp - 4000;
        end else if (temp >= 3000) begin
            bcd_thousands = 4'd3; temp = temp - 3000;
        end else if (temp >= 2000) begin
            bcd_thousands = 4'd2; temp = temp - 2000;
        end else if (temp >= 1000) begin
            bcd_thousands = 4'd1; temp = temp - 1000;
        end else begin
            bcd_thousands = 4'd0;
        end

        // HUNDREDS
        if (temp >= 900) begin
            bcd_hundreds = 4'd9; temp = temp - 900;
        end else if (temp >= 800) begin
            bcd_hundreds = 4'd8; temp = temp - 800;
        end else if (temp >= 700) begin
            bcd_hundreds = 4'd7; temp = temp - 700;
        end else if (temp >= 600) begin
            bcd_hundreds = 4'd6; temp = temp - 600;
        end else if (temp >= 500) begin
            bcd_hundreds = 4'd5; temp = temp - 500;
        end else if (temp >= 400) begin
            bcd_hundreds = 4'd4; temp = temp - 400;
        end else if (temp >= 300) begin
            bcd_hundreds = 4'd3; temp = temp - 300;
        end else if (temp >= 200) begin
            bcd_hundreds = 4'd2; temp = temp - 200;
        end else if (temp >= 100) begin
            bcd_hundreds = 4'd1; temp = temp - 100;
        end else begin
            bcd_hundreds = 4'd0;
        end

        // TENS
        if (temp >= 90) begin
            bcd_tens = 4'd9; temp = temp - 90;
        end else if (temp >= 80) begin
            bcd_tens = 4'd8; temp = temp - 80;
        end else if (temp >= 70) begin
            bcd_tens = 4'd7; temp = temp - 70;
        end else if (temp >= 60) begin
            bcd_tens = 4'd6; temp = temp - 60;
        end else if (temp >= 50) begin
            bcd_tens = 4'd5; temp = temp - 50;
        end else if (temp >= 40) begin
            bcd_tens = 4'd4; temp = temp - 40;
        end else if (temp >= 30) begin
            bcd_tens = 4'd3; temp = temp - 30;
        end else if (temp >= 20) begin
            bcd_tens = 4'd2; temp = temp - 20;
        end else if (temp >= 10) begin
            bcd_tens = 4'd1; temp = temp - 10;
        end else begin
            bcd_tens = 4'd0;
        end

        // ONES
        /*bcd_ones = temp[3:0];*/
        bcd_ones = (temp < 10) ? temp[3:0] : 4'd0;
    end
endmodule

