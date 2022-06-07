module signed_right_shift
#(
    parameter N_SHIFT_BITS = 1, // number of bits to shift
    parameter WIDTH = 24
)
(
    input   [WIDTH-1:0] in,
    output  [WIDTH-1:0] out
);

    assign out = { { N_SHIFT_BITS{in[WIDTH-1]} }, in[WIDTH-1:N_SHIFT_BITS] };

endmodule
