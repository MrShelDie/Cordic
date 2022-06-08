`timescale 1ns / 1ps

module cordic_pipe_stage
#(
    parameter NUM_WIDTH     = 24,
    parameter ATAN          = 0    // the parameter must be overrided
)
(
    input                       clk,
    input                       rst,
    input                       enabled,

    input       [NUM_WIDTH-1:0] ix,
    input       [NUM_WIDTH-1:0] iy,
    input       [NUM_WIDTH-1:0] iz,

    input       [NUM_WIDTH-1:0] shifted_x,
    input       [NUM_WIDTH-1:0] shifted_y,

    output  reg [NUM_WIDTH-1:0] ox,
    output  reg [NUM_WIDTH-1:0] oy,
    output  reg [NUM_WIDTH-1:0] oz
);

    always @(posedge clk or posedge rst)
        if (rst) begin
            ox <= 0;
            oy <= 0;
            oz <= 0;
        end
        else if (enabled) begin
            if (iz[NUM_WIDTH-1]) begin   // check if z negative
                ox <= ix + shifted_y;
                oy <= iy - shifted_x;
                oz <= iz + ATAN;
            end
            else begin
                ox <= ix - shifted_y;
                oy <= iy + shifted_x;
                oz <= iz - ATAN;
            end
        end

endmodule
