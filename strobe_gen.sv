module strobe_gen
(
    input   clk,
    input   rst,
    input   in,
    output  out
);

    reg n_in_reg;

    always @(posedge clk or posedge rst)
        if (rst)
            n_in_reg <= 0;
        else
            n_in_reg <= ~in;

    assign out = in && n_in_reg;

endmodule
