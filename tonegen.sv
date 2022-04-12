module tonegen#( parameter logic [31:0] fclk ) // clock frequency, Hz
(   input   logic [31:0] writedata,  // Avalon MM bus, data
    input   logic write,             // write enable
    output  logic spkr,              // output for audio
    input   logic reset, clk ) ;     // active high reset and clock

    reg[31:0] capture_write_data;
    reg[31:0] fcount;
    reg[31:0] fcount_max;
                                             //Set the freq for non zero capture      //set the count to 'f if capture is 0;
    assign fcount_max = capture_write_data ? (fclk / (2*capture_write_data))    :    '1; 
    
    always_ff @ (negedge clk) begin
        capture_write_data <= write ? writedata : capture_write_data; // gate the capture data behind the write signal,
                                                                      // maintain previous value for ~write
    end

    always_ff @ (posedge clk) begin
        if(reset) begin
            fcount              <=  1;
            spkr                <= '0;
        end
        else begin
            if(fcount > (fcount_max-1)) begin
                spkr    <= ~spkr;
                fcount  <= 1;// set the counter to 1 because of timing issues
            end
            else begin
                fcount <= fcount + 1;
            end
        end 
    end

endmodule