module cordic_pipe_stage
#(
    parameter NUM_WIDTH = 24,
    parameter atan      = 0,    // the parameter must be overrided
    parameter shift		= 0		// the parameter must be overrided
)
(
    input                       clk,
    input                       rst,
    input                       enabled,

    input   reg [NUM_WIDTH-1:0] ix,
    input   reg [NUM_WIDTH-1:0] iy,
    input   reg [NUM_WIDTH-1:0] iz,    

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
                ox <= ix + (iy >> shift);
                oy <= iy - (ix >> shift);
                oz <= iz + atan;
            end
            else begin
                ox <= ix - (iy >> shift);
                oy <= iy + (ix >> shift);
                oz <= iz - atan;
            end
        end

endmodule
