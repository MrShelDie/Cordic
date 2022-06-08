`timescale 1ns / 1ps

`define PIPE

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

    localparam angle_cnt = 10;

    localparam [23:0] angles [0:angle_cnt-1] = {
        24'b0001_1001_0001_1110_1011_1000,  // 1.57
        24'b0001_0000_0000_0000_0000_0000,  // 1
        24'b0000_1100_1100_1100_1100_1100,  // 0.8
        24'b0000_1000_0000_0000_0000_0000,  // 0.5
        24'b0000_0100_1100_1100_1100_1100,  // 0.3
        24'b0000_0000_0000_0000_0000_0000,  // 0
        24'b1111_1111_1101_0111_0000_1011,  // -0.01
        24'b1111_1000_0000_0000_0000_0000,  // -0.5
        24'b1111_0000_0000_0000_0000_0000,  // -1
        24'b1110_0110_1110_0001_0100_1000   // -1.57
    };

    localparam [23:0] sin_values [0:angle_cnt-1] = {
        24'b0000_1111_1111_1111_1111_1111,  // 0.999999682931835
        24'b0000_1101_0111_0110_1010_1010,  // 0.841470984807897
        24'b0000_1011_0111_1010_0100_1010,  // 0.717356090899523
        24'b0000_0111_1010_1011_1011_1010,  // 0.479425538604203
        24'b0000_0100_1011_1010_0111_0011,  // 0.295520206661340
        24'b0000_0000_0000_0000_0000_0000,  // 0
        24'b1111_1111_1101_0111_0000_1011,  // -0.009999833334167
        24'b1111_1000_0101_0100_0100_0110,  // -0.479425538604203
        24'b1111_0010_1000_1001_0101_0110,  // -0.841470984807897
        24'b1111_0000_0000_0000_0000_0001   // -0.999999682931835
    };

    localparam [23:0] cos_values [0:angle_cnt-1] = {
        24'b0000_0000_0000_0011_0100_0011,  // 0.000796326710733
        24'b0000_1000_1010_0101_0001_0100,  // 0.540302305868140
        24'b0000_1011_0010_0101_1011_0101,  // 0.696706709347165
        24'b0000_1110_0000_1010_1001_0100,  // 0.877582561890373
        24'b0000_1111_0100_1001_0000_1110,  // 0.955336489125606
        24'b0001_0000_0000_0000_0000_0000,  // 1
        24'b0000_1111_1111_1111_1100_1011,  // 0.999950000416665
        24'b0000_1110_0000_1010_1001_0100,  // 0.877582561890373
        24'b0000_1000_1010_0101_0001_0100,  // 0.540302305868140
        24'b0000_0000_0000_0011_0100_0011   // 0.000796326710733
    };

    `ifdef PIPE
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
    `else
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
    `endif  // PIPE

    initial
        forever #1 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        angle <= 0;
		data_loaded = 0;
        #5
        rst <= 0;
        #5
        $display("\nTest started...\n");

        `ifndef PIPE
            for (integer i = 0; i < angle_cnt; ++i) begin
                load_angle(angles[i]);
                check_result(angles[i], sin_values[i], cos_values[i]);
            end
        `else
            for (integer i = 0; i < angle_cnt / 2; ++i)
                load_angle(angles[i]);
            for (integer i = 0; i < angle_cnt / 2; ++i)
                check_result(angles[i], sin_values[i], cos_values[i]);
            for (integer i = angle_cnt / 2; i < angle_cnt; ++i)
                load_angle(angles[i]);
            for (integer i = angle_cnt / 2; i < angle_cnt; ++i)
                check_result(angles[i], sin_values[i], cos_values[i]);
        `endif  // PIPE

        $display("TEST PASSED!!!\n");
    end

    task load_angle(input [23:0] checked_angle);
        #2
        angle <= checked_angle;
        #2
        data_loaded <= 1;
        #2
        data_loaded <= 0;
    endtask // load_angle

    task check_result(input [23:0] checked_angle, input [23:0] true_sin, input [23:0] true_cos);
        @(posedge data_computed)
        if (y[WIDTH-1:WIDTH-16] != true_sin[WIDTH-1:WIDTH-16]) begin
            $display("TEST FAILED in task sin(%b):\nexpected\t %b\nreceived\t %b\n", checked_angle, true_sin, y);
            $finish;
        end
        else if (x[WIDTH-1:WIDTH-16] != true_cos[WIDTH-1:WIDTH-16]) begin
            $display("TEST FAILED in task cos(%b):\nexpected\t %b\nreceived\t %b\n", checked_angle, true_cos, x);
            $finish;
        end
    endtask // check_result

endmodule
