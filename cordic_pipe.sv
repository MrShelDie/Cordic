module cordic_pipe
#(
    parameter NUM_WIDTH     = 24,   // number of bits in a number
    parameter COUNTER_WIDTH = 5,    // number of bits in iteration counter
    parameter STAGE_CNT     = 19,   // count of iteration
    parameter CORDIC_RATIO
      = 24'b0000_10011011011101001110, // the ratio in the cordic formula
    parameter [23:0] atan [0:19] = {
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

    reg [STAGE_CNT:0]   stage_states;
    reg [STAGE_CNT-1:0] counter;
    reg                 enabled;

    always @(posedge clk or posedge rst) begin
        if (rst)
            stage_states <= 0;
        else if (data_loaded_strobe)
            stage_states <= { 1'b1, stage_states[STAGE_CNT:1] };
        else
            stage_states <= { 1'b0, stage_states[STAGE_CNT:1] };
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_computed <= 0;
        else if (stage_states[0])
            data_computed <= 1;
        else
            data_computed <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || counter >= STAGE_CNT) begin
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

    generate 
        genvar i;
        for (i = 0; i < STAGE_CNT; i = i + 1) begin : pipe
            cordic_pipe_stage #(.atan(atan[i]), .shift(i))
            cordic_pipe_stage_inst
            (
                .clk(clk),
                .rst(rst),
                .enabled(enabled),

                .ix(stage_link_x[i]),
                .iy(stage_link_y[i]),
                .iz(stage_link_z[i]),

                .ox(stage_link_x[i + 1]),
                .oy(stage_link_y[i + 1]),
                .oz(stage_link_z[i + 1])              
            );
        end
    endgenerate

endmodule
