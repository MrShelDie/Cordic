module cordic_iter
#(
	parameter ARG_WIDTH 	= 24, 		// number of bits in a number
	parameter ITER_WIDTH 	= 5,		// number of bits in iteration counter
	parameter ITER_CNT		= 19,		// count of iteration
	parameter CORDIC_RATIO
	  = 24'b0000_10011011011101001110,	// the ratio in the cordic formula
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
	input 						clk,
	input 						rst,
	input						data_loaded,
	input	[ARG_WIDTH-1:0]		angle,

	output 	reg [ARG_WIDTH-1:0] x,
	output	reg [ARG_WIDTH-1:0]	y,
	output	reg 				data_computed
);

	reg 	[ITER_WIDTH-1:0]	i;
	reg		[ARG_WIDTH-1:0]		z;
	reg 						enabled;
	
	wire data_loaded_strobe;

    strobe_gen	strobe_gen_load_data
    (
        .clk(clk),
        .rst(rst),
        .in(data_loaded),
        .out(data_loaded_strobe)
    );

    wire [ARG_WIDTH-1:0] signed_right_shift_x [ITER_CNT + 1];
    wire [ARG_WIDTH-1:0] signed_right_shift_y [ITER_CNT + 1];

    generate
    	genvar j;
    	for (j = 0; j < ITER_CNT + 1; j = j + 1) begin:shift

    		signed_right_shift #(.N_SHIFT_BITS(j))
    		signed_right_shift_x_unit
    		(
    			.in(x),
    			.out(signed_right_shift_x[j])
    		);

    		signed_right_shift #(.N_SHIFT_BITS(j))
    		signed_right_shift_y_unit
    		(
    			.in(y),
    			.out(signed_right_shift_y[j])
    		);

    	end
    endgenerate

    always @(posedge clk or posedge rst) begin
    	if (rst || i >= ITER_CNT) begin
    		enabled <= 0;
    		i <= 0;
    	end
    	else if (data_loaded_strobe && !enabled) begin
    		enabled <= 1;
    		i <= 0;
    	end
    	else if (enabled)
    		i <= i + 1;
    end

	always @(posedge clk or posedge rst) begin
		if (rst || i < 19)
			data_computed <= 0;
		else
			data_computed <= 1;
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			x <= CORDIC_RATIO;
			y <= 0;
			z <= 0;
		end
		else if (data_loaded_strobe) begin
			x <= CORDIC_RATIO;
			y <= 0;
			z <= angle;
		end
		else if (enabled) begin
			if (z[ARG_WIDTH-1]) begin 	// check if z negative
				x <= x + signed_right_shift_y[i];
				y <= y - signed_right_shift_x[i];
				z <= z + atan[i];
			end
			else begin
				x <= x - signed_right_shift_y[i];
				y <= y + signed_right_shift_x[i];
				z <= z - atan[i];
			end
		end
	end

endmodule
