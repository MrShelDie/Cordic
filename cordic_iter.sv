module cordic_iter
#(
	parameter NUM_WIDTH 	= 24, 	// number of bits in a number
	parameter ITER_WIDTH 	= 5,	// number of bits in iteration counter
	parameter ITER_CNT		= 19,    // count of iteration
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
	input 						clk,
	input 						rst,
	input						data_loaded,
	input	[NUM_WIDTH-1:0]		angle,

	output 	reg [NUM_WIDTH-1:0] x,
	output	reg [NUM_WIDTH-1:0]	y,
	output	reg 				data_computed
);

	reg 	[ITER_WIDTH-1:0]	i;
	reg		[NUM_WIDTH-1:0]		z;
	reg							n_data_loaded_reg;
	reg							run_computing;
	
	wire new_data = data_computed && data_loaded && n_data_loaded_reg;
	wire is_cicle_end = i >= 19;

	// TODO replace to strobe_gen
	always @(posedge clk or posedge rst)
		if (rst)
			n_data_loaded_reg <= 0;
		else
			n_data_loaded_reg <= ~data_loaded;

	always @(posedge rst or posedge new_data or posedge is_cicle_end)
		if (rst || is_cicle_end)
			data_computed <= 1;
		else if (new_data)
			data_computed <= 0;

	always @(posedge clk or posedge rst or posedge new_data)
		if (rst) begin
			i <= ITER_CNT + 1;
			x <= CORDIC_RATIO;
			y <= 0;
			z <= 0;
		end
		else if (new_data) begin
			i <= 0;
			x <= CORDIC_RATIO;
			y <= 0;
			z <= angle;
		end
		else if (!is_cicle_end) begin
			i <= i + 1;
			if (z[NUM_WIDTH-1]) begin 	// check if z negative
				x <= x + (y >> i);
				y <= y - (x >> i);
				z <= z + atan[i];
			end
			else begin
				x <= x - (y >> i);
				y <= y + (x >> i);
				z <= z - atan[i];
			end
		end

endmodule
