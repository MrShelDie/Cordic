`timescale 1ns / 1ps

module strobe_gen
(
    input   clk,
    input   rst,
    input   in,
    output  out
);

    reg n_in;

    always @(posedge clk or posedge rst)
        if (rst)
            n_in <= 1'B0;
        else
            n_in <= ~in;

    assign out = in & n_in;

endmodule
