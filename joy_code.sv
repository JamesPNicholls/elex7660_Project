module joy_code(
    input logic clk, reset_n,
    input logic [11:0] adc_y, adc_x,
    input logic [2:0]  num_1, num_2, num_3, num_4,
    input logic [2:0]  key_press,

    output logic [1:0] quadrant_out,
    output logic pass_flag,
	 output logic q_match,
	 output logic [2:0] joy_state
);

logic[1:0] quadrant;
logic pos_match;
assign q_match = pos_match;
assign quadrant = num_1 % 4;
assign quadrant_out = quadrant;
assign joy_state = current_state;

always_comb begin
    if((adc_x > 12'h800) && (quadrant == 0)) 
        pos_match <= 1;
    else if( (adc_x < 12'h600) && (quadrant == 1))
        pos_match <= 1;
    else if ((adc_y > 12'h800) && (quadrant == 2)) begin
        pos_match <= 1;
    end
    else if ((adc_y < 12'h600) && (quadrant == 3)) begin
        pos_match <= 1;
    end

    else
        pos_match <= 0;
end

logic [2:0] current_state, next_state;
localparam [2:0]
    s_one = 0,
    s_two = 1,
    s_three = 2,
    s_four  = 3,
    s_pass  = 4;

always_comb begin : state_logic
    case (current_state)
        s_one     : begin
                        pass_flag <= 0;
                        current_state <= next_state;
                    end
        s_two     : begin
                        pass_flag <= 0;
                        current_state <= next_state;
                    end
        s_three   : begin
                        pass_flag <= 0;
                        current_state <= next_state;
                    end
        s_four    : begin
                        pass_flag <= 0;
                        current_state <= next_state;
                    end
        s_pass    : begin
                        pass_flag <= 1; // flag goes high once the 4 numbers have inputed 
                        current_state <= next_state;
                    end

        default: begin
            current_state <= next_state;
            pass_flag <= 0;
        end
    endcase
end : state_logic

always_ff @(posedge clk or negedge reset_n) begin : state_handler
    if(~reset_n)
        next_state <= s_one;
    else begin
        case (current_state)
            // If key_press matches the numnber value AND the cursor is in the right postion advance the state
            s_one     : next_state = ((key_press == num_1) && pos_match == 1) ? s_two   : current_state;
            s_two     : next_state = ((key_press == num_2) && pos_match == 1) ? s_three : current_state;
            s_three   : next_state = ((key_press == num_3) && pos_match == 1) ? s_four  : current_state;
            s_four    : next_state = ((key_press == num_4) && pos_match == 1) ? s_pass  : current_state;
            s_pass    : next_state = (~reset_n) ? s_one : current_state;
        default: begin
            next_state <= s_one;
        end
    endcase
    
    end

end : state_handler

    
endmodule