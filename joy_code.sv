module joy_code(
    input logic clk, reset_n,
    input logic [11:0] adc_y, adc_x,
    input logic [2:0]  num_1, num_2, num_3, num_4,
    input logic [3:0]  key_press,
    output logic [1:0] quadrant_out,

    output logic pass_flag,
	 output logic q_match,
    output logic [2:0] joy_state
);

logic [2:0] current_state, next_state;
localparam [2:0]
    s_one = 0,
    s_two = 1,
    s_three = 2,
    s_four  = 3,
    s_pass  = 4;

logic[1:0] quadrant;
logic pos_match;
assign q_match = pos_match;
assign quadrant = num_1 % 4;
assign quadrant_out = quadrant;
assign joy_state = current_state;

always_comb begin
    if( (adc_x > 12'h700))
        pos_match <= 1;        
    else
        pos_match <= 0;
end

assign pass_flag = current_state == s_pass ? 1 : 0;

always_comb begin : state_logic
    case (current_state)
        s_one     : begin
 
                        current_state <= next_state;
                    end
        s_two     : begin
                   
                        current_state <= next_state;
                    end
        s_three   : begin
              
                        current_state <= next_state;
                    end
        s_four    : begin

                        current_state <= next_state;
                    end

        s_pass    : begin
                        current_state <= next_state;
                    end

        default: begin
            current_state<= s_one;
        end
    endcase
end : state_logic

always_ff @(posedge clk, negedge reset_n) begin : state_handler
    if(~reset_n)
        next_state <= s_one;
    else begin
        case (current_state)
            // If key_press matches the numnber value AND the cursor is in the right postion advance the state
            s_one     : next_state = ((key_press[2:0] == num_1) && (pos_match)) ? s_two   : current_state;
            s_two     : next_state = ((key_press[2:0] == num_2) && (pos_match)) ? s_three : current_state;
            s_three   : next_state = ((key_press[2:0] == num_3) && (pos_match)) ? s_four  : current_state;
            s_four    : next_state = ((key_press[2:0] == num_4) && (pos_match)) ? s_pass  : current_state;
            s_pass    : next_state = s_one;
        default: begin
            next_state <= s_one;
        end
    endcase
    
    end

end : state_handler

    
endmodule