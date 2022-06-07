`timescale 1ns / 1ps

// `define PIPE

module testbench
#(
    parameter WIDTH = 24
)
();

    reg             clk;
    reg             rst;
    reg     [23:0]  angle;

    wire    [23:0]  x;
    wire    [23:0]  y;

    reg             data_loaded;
    wire            data_computed;

// `ifdef PIPE

// 	cordic_pipe cordic_pipe_inst
//     (
//         .clk(clk),
//         .rst(rst),
//         .angle(angle),

//         .x(x),
//         .y(y),

//         .data_loaded(data_loaded),
//         .data_computed(data_computed)
//     );

// `else

    cordic_iter cordic_iter_0
    (
       .clk(clk),
       .rst(rst),
       .angle(angle),

       .x(x),
       .y(y),

       .data_loaded(data_loaded),
       .data_computed(data_computed)
    );
    
// `endif

    initial begin
        clk = 0;
        rst = 1;
        angle <= 0;
		data_loaded = 0;

        #10
        rst <= 0;

        #10
        $display("Test started...");
        // sin(1.57);
        sin(24'b0001_1001_0001_1110_1011_1000,  // 1.57
            24'b0000_1111_1111_1111_1111_1111); // 0.999999682931835
        // sin(1)
        sin(24'b0001_0000_0000_0000_0000_0000,  // 1
            24'b0000_1101_0111_0110_1010_1010); // 0.841470984807897
        // sin(0.8)
        sin(24'b0000_1100_1100_1100_1100_1100,  // 0.8
            24'b0000_1011_0111_1010_0100_1010); // 0.717356090899523
        // sin(0.5)
        sin(24'b0000_1000_0000_0000_0000_0000,  // 0.5
            24'b0000_0111_1010_1011_1011_1010); // 0.479425538604203
        // sin(0.3)
        sin(24'b0000_0100_1100_1100_1100_1100,  // 0.3
            24'b0000_0100_1011_1010_0111_0011); // 0.295520206661340
        // sin(0)
        sin(24'b0000_0000_0000_0000_0000_0000,  // 0
            24'b0000_0000_0000_0000_0000_0000); // 0
        // sin(-0.01)
        sin(24'b1111_1111_1101_0111_0000_1011,  // -0.01
            24'b1111_1111_1101_0111_0000_1011); // -0.009999833334167
        //sin(-0.5)
        sin(24'b1111_1000_0000_0000_0000_0000,  // -0.5
            24'b1111_1000_0101_0100_0100_0110); // -0.479425538604203
        // sin(-1)
        sin(24'b1111_0000_0000_0000_0000_0000,  // -1
            24'b1111_0010_1000_1001_0101_0110); // -0.841470984807897
        // sin(-1.57)
        sin(24'b1110_0110_1110_0001_0100_1000,  // -1.57
            24'b1111_0000_0000_0000_0000_0001); // -0.999999682931835
        $display("The test is over...");
    end

    task sin(input [23:0] checked_angle, input [23:0] true_value);
        angle <= checked_angle;
        #10 
        data_loaded <= 1;
        #10
        data_loaded <= 0;
        @(posedge data_computed)
        if (y[WIDTH-1:WIDTH-16] != true_value[WIDTH-1:WIDTH-16])
            $display("\nTEST FAILED:\nexpected\t %b\nreceived\t %b\n", true_value, y);
    endtask

	initial
		forever #1 clk = ~clk;

endmodule
