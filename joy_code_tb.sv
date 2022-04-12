module joy_code_tb();

    logic clk, reset_n;
    logic [11:0] adc_y, adc_x;
    logic [2:0]  num_1, num_2, num_3, num_4;
    logic [3:0]  key_press;
    logic [1:0] quadrant_out;

    logic pass_flag;
	logic q_match;
	logic [2:0] joy_state;
    joy_code uut(.*);

    initial begin
        clk = 0;
        reset_n = 0;
        @(posedge clk)
            reset_n = 1;

        num_1 = 1;
        num_2 = 2;
        num_3 = 3;
        num_4 = 4;

        for(int i = 0; i < 8; i++) begin
            adc_y = 12'h900;
            adc_x = 12'h000;
            key_press = i;
            @ (posedge clk);
        end

        for(int i = 0; i < 8; i++) begin
            adc_y = 12'h0000;
            adc_x = 12'h900;
            key_press = i;
            @ (posedge clk);
        end
                for(int i = 0; i < 8; i++) begin
            adc_y = 12'h900;
            adc_x = 12'h000;
            key_press = i;
            @ (posedge clk);
        end
        
        for(int i = 0; i < 8; i++) begin
            adc_y = 12'h900;
            adc_x = 12'h900;
            key_press = i;
            @ (posedge clk);
        end
        $stop;
        
    end

    always
        #500us clk = ~clk;

endmodule