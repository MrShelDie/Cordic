`timescale 1ns / 1ps

module cordic_pipe
#(
    parameter NUM_WIDTH     = 24,   // number of bits in a number
    parameter COUNTER_WIDTH = 5,    // number of bits in iteration counter
    parameter STAGE_CNT     = 20,   // count of iteration
    parameter CORDIC_RATIO
      = 24'b0000_10011011011101001110, // the ratio in the cordic formula
    parameter [23:0] ATAN [0:STAGE_CNT-1] = {
        24'b0000_11001001000011111101,
        24'b0000_01110110101100011001,
        24'b0000_00111110101101101110,
        24'b0000_00011111110101011011,
        24'b0000_00001111111110101010,
        24'b0000_00000111111111110101,
        24'b0000_00000011111111111110,
        24'b0000_00000001111111111111,
        24'b0000_00000000111111111111,
        24'b0000_00000000011111111111,
        24'b0000_00000000001111111111,
        24'b0000_00000000000111111111,
        24'b0000_00000000000011111111,
        24'b0000_00000000000001111111,
        24'b0000_00000000000000111111,
        24'b0000_00000000000000011111,
        24'b0000_00000000000000001111,
        24'b0000_00000000000000000111,
        24'b0000_00000000000000000011,
        24'b0000_00000000000000000001
    }
)
(
    input                       clk,
    input                       rst,
    input                       data_loaded,
    input   [NUM_WIDTH-1:0]     angle,

    output  reg [NUM_WIDTH-1:0] x,
    output  reg [NUM_WIDTH-1:0] y,
    output  reg                 data_computed
);

    wire data_loaded_strobe;

    strobe_gen strobe_gen_load_data
    (
        .clk(clk),
        .rst(rst),
        .in(data_loaded),
        .out(data_loaded_strobe)
    );

    reg [STAGE_CNT:0]       stage_states;   // one additional stage to save data_loaded_strobe
    reg [COUNTER_WIDTH-1:0] counter;
    reg                     enabled;

    always @(posedge clk or posedge rst) begin
        if (rst)
            stage_states <= 0;
        else if (data_loaded_strobe)
            stage_states <= { stage_states[STAGE_CNT-1:0], 1'b1 };
        else
            stage_states <= { stage_states[STAGE_CNT-1:0], 1'b0 };
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_computed <= 0;
        else if (stage_states[STAGE_CNT])
            data_computed <= 1;
        else
            data_computed <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || counter >= STAGE_CNT - 1) begin
            enabled <= 0;
            counter <= 0;
        end
        else if (data_loaded_strobe) begin
            enabled <= 1;
            counter <= 0;
        end
        else if (enabled)
            counter <= counter + 1;
    end

	wire [NUM_WIDTH-1:0] stage_link_x [STAGE_CNT + 1];
	wire [NUM_WIDTH-1:0] stage_link_y [STAGE_CNT + 1];
	wire [NUM_WIDTH-1:0] stage_link_z [STAGE_CNT + 1];

	assign stage_link_x[0] = CORDIC_RATIO;
	assign stage_link_y[0] = 0;
	assign stage_link_z[0] = angle;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			x <= 0;
			y <= 0;
		end
		else begin
			x <= stage_link_x[STAGE_CNT];
			y <= stage_link_y[STAGE_CNT];
		end
	end

    wire [NUM_WIDTH-1:0] shifted_x [STAGE_CNT];
    wire [NUM_WIDTH-1:0] shifted_y [STAGE_CNT];

	assign shifted_x[0] = CORDIC_RATIO;
	assign shifted_y[0] = 0;

    generate 
        genvar i;
        for (i = 1; i < STAGE_CNT; i = i + 1) begin : shift
            assign shifted_x[i] = { { i{stage_link_x[i][NUM_WIDTH-1]} }, stage_link_x[i][NUM_WIDTH-1:i] };
            assign shifted_y[i] = { { i{stage_link_y[i][NUM_WIDTH-1]} }, stage_link_y[i][NUM_WIDTH-1:i] };
        end
        for (i = 0; i < STAGE_CNT; i = i + 1) begin : stage
            cordic_pipe_stage #(.ATAN(ATAN[i]))
            cordic_pipe_stage_inst
            (
                .clk(clk),
                .rst(rst),
                .enabled(enabled),

                .ix(stage_link_x[i]),
                .iy(stage_link_y[i]),
                .iz(stage_link_z[i]),

                .shifted_x(shifted_x[i]),
                .shifted_y(shifted_y[i]),

                .ox(stage_link_x[i + 1]),
                .oy(stage_link_y[i + 1]),
                .oz(stage_link_z[i + 1])              
            );
        end
    endgenerate

endmodule
