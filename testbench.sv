`timescale 1ns / 1ps

module testbench();

    reg             clk;
    reg             rst;
    reg     [23:0]  angle;

    wire    [23:0]  x;
    wire    [23:0]  y;

    reg             data_loaded;
    wire            data_computed;

//    cordic_iter cordic_iter_0
//    (
//        .clk(clk),
//        .rst(rst),
//        .angle(angle),

//        .x(x),
//        .y(y),

//        .data_loaded(data_loaded),
//        .data_computed(data_computed)
//    );

	cordic_pipe cordic_pipe_inst
    (
        .clk(clk),
        .rst(rst),
        .angle(angle),

        .x(x),
        .y(y),

        .data_loaded(data_loaded),
        .data_computed(data_computed)
    );

    initial begin
        clk = 0;
        rst = 1;
		data_loaded = 0;
//        $display("Running testbench\n");

        #100
        rst = 0;
        #100
        angle = 24'b0000_10000000000000000000;
        #130
        data_loaded = 1;
        #100
        data_loaded = 0;
        
        #100
        angle = 24'b0000_11000000000000000000;
		#100
		data_loaded = 1;
		#100
		data_loaded = 0;
        

    end  

	initial
		forever #15 clk = ~clk;

//    initial
//        #1000 $monitor("sin = %b\ncos = %b", y, x);

endmodule
