/*********************************************************************
*BankVault Module (Top-level heirarchy)
*
*Date: 2/25/2022
*
*Author: Mo Amirian, Clint Gaudet, James Nicholls
*
*Class: ELEX 7660 - Digital System Design
*
*Module Description: 
*	Top level Entity used to handle state machine and individual modules
*
*
*
**********************************************************************/
`define KP_POWER 4'hd
`define X_CHANNEL 1
`define Y_CHANNEL 0

module bankVault ( 
    // Clk
    input logic FPGA_CLK1_50,

    //7-seg, LEDS, kpad
    output logic [3:0] kpc,  // column select, active-low
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *)
    input logic  [3:0] kpr,  // rows, active-low w/ pull-ups
    output logic [7:0] leds, // active-low LED segments 
    output logic [3:0] ct,   // " digit enables
    output logic [7:0] LED,  // 8 green LEDS next to ethernet connector

    // ADC interface
    output ADC_CONVST, ADC_SCK, ADC_SDI,  
    input ADC_SDO,
    input logic  reset_n, 

    //Clint spank
    inout logic[3:0] GPIO_1,

    //OLED Controls
    output logic rgb_din, rgb_clk, rgb_cs, rgb_dc, rgb_res,

    //speaker takes a PWM
    output spkr
) ;

  logic clk ;               // clock
  logic [11:0] adcValue;    // ADC result    
  logic [4:0] displayNum;	  // number to display on 7-seg
  logic [3:0] kpNum; 		    // keypad output
  logic [2:0] digit;        // 7-seg display digit currently selected
  logic [7:0] delayCnt;     // delay count to slow down digit cycling on display
  logic kphit;              // keypad button press indicator
  logic kphit_debounced;              // keypad button press indicator

	pll pll0 ( .inclk0(FPGA_CLK1_50), .c0(clk) ) ;

	// instantiate your modules here...
	decode7 decode7_0 (.num(displayNum), .leds) ;
	kpdecode kpdecode_0 (.kpr, .kpc, .kphit, .num(kpNum)) ;
	colseq colseq_0 (.clk, .reset_n, .kpr, .kpc);

  // Buttons make spkr go brrrrrrrrrrrrrrr
 beep_beep beep_boop( .clk, .enable(kphit), .spkr_on(sprk));

	
  // ADC interface signals   
  logic [3:0] adc_chan;
  logic [11:0] adc_x_value;
  logic [11:0] adc_y_value;
	
	// Stuff for CLintin's moduel
	logic emag_state_flag;
  logic emag_state_flag_2;
	logic emag_out_flag;
	logic emag_rand;
	safe_tilt_and_unlock safe_0( .knock_input(GPIO_1[1]), .enable(game_3_en), .reset_n, .CLOCK_50(FPGA_CLK1_50), .output_elmag(emag_rand), .unlocked_flag(emag_state_flag));
  safe_tilt_and_unlock safe_1( .knock_input(GPIO_1[1]), .enable(game_4_en), .reset_n, .CLOCK_50(FPGA_CLK1_50), .output_elmag(emag_out_flag), .unlocked_flag(emag_state_flag_2));
  

  //*************************James Game
  logic[1:0] quadrant_out;
  logic q_match;
  logic james_flag;
  logic [2:0] joy_state;
  
	joy_code joy_code_0(  .clk, .enable(game_2_en), .reset_n, 
                        .adc_y(adc_y_value), .adc_x(adc_x_value), 
                        //Nums are setting by the RNG code block lower
                        .num_1(r_num_0),  .num_2(r_num_1), .num_3(r_num_2), .num_4(r_num_3),
                        .key_press(kpNum),
                        .quadrant_out(quadrant_out), .pass_flag(james_flag), .q_match(q_match), .joy_state(joy_state));                  
   //Some debug code
  always_ff @ (posedge clk) begin
		LED[7:5]    <= current_state;
		LED[4] 		  <= q_match;
		LED[3]      <= james_flag;
		LED[2:0]    <= joy_state;
	end
	/*******************************James Game */
  
  
  adcinterface adcinterface_X(  .clk, .reset_n,  .chan(adc_chan), .result(adcValue), .ADC_CONVST, .ADC_SCK, .ADC_SDI, .ADC_SDO);
    
  //Toggles the channel on the ADC to alternate sampling X and Y axis
   always_ff @(posedge clk ) begin

    if ((adc_chan == `X_CHANNEL) && ADC_CONVST) begin      
      //Store Value
      adc_x_value = adcValue; 
      // Send signal to PI
      //Set channel to poll the other channel
      adc_chan[0] = `Y_CHANNEL;

    end else if((adc_chan == `Y_CHANNEL)  && ADC_CONVST) begin
      adc_y_value = adcValue;
      adc_chan[0] = `X_CHANNEL;
    end

  end

  // Processor Instantiation
  processor u0 (
		.clk_clk       (FPGA_CLK1_50),    // clk.clk
		.gpio_in_port  (rgb_input),       // gpio.in_port
		.gpio_out_port (rgb_output),      // gpio.out_port
		.reset_reset_n (rgb_res),         // reset.reset_n
		.spi_MISO      ('0),              // spi.MISO
		.spi_MOSI      (rgb_din),         // .MOSI
		.spi_SCLK      (rgb_clk),         // .SCLK
		.spi_SS_n      (rgb_cs)           // .SS_n
	);

 //Signals to be sent to and from the processor
  wire [31:0]rgb_output;
  wire [31:0]rgb_input;
  assign rgb_dc = rgb_output[0]; 
  assign rgb_res =   reset_n || (((kpNum[3:0] == `KP_POWER) & kphit) ? 0 : 1); //Power button on kpad for reset

	// Values are set in the state machine
  logic[4:0] disp_num_0;
  logic[4:0] disp_num_1;  
  logic[4:0] disp_num_2;
  logic[4:0] disp_num_3;
	always_comb
	case( digit )
        3 : displayNum <= disp_num_0;
        2 : displayNum <= disp_num_1;
        1 : displayNum <= disp_num_2;
        0 : displayNum <= disp_num_3;
		default: 
           displayNum = 'hf ; 
    endcase


	//Generates some random numbers to be used for Mo's and James's Game
	// select the bits from the 12-bit ADC result for the selected digit
	logic [3:0] r_num_3, r_num_2, r_num_1, r_num_0;
	always_ff @ (posedge clk) begin : rn_generator
		if(~reset_n) begin
			r_num_3 <= 0;
			r_num_2 <= 0; 
			r_num_1 <= 0; 
			r_num_0 <= 0;
		end else begin
			if(current_state != game_2) begin
				r_num_3 <= { 1'b0, adcValue[2:0]};
				r_num_2 <= { 1'b0, adcValue[6:4]}; 
				r_num_1 <= { 1'b0, adcValue[8:6]}; 
				r_num_0 <= { 1'b0, adcValue[4:2]};
			end else begin
				r_num_3 <= r_num_3;
				r_num_2 <= r_num_2; 
				r_num_1 <= r_num_1; 
				r_num_0 <= r_num_0;
			end
		end
	
  end : rn_generator

//**********************Mo Game***********************
  logic [19:0] game_one_bits;
  logic [2:0] game_one_counter;
  logic mo_flag;
  logic ctTemp; 

	gameOne gameOne_0 (.clk, .enable(game_1_en), .reset_n, .bits(game_one_bits), .victoryflag(mo_flag), .gameCounter(game_one_counter));
	debounce debounce_0 (.clk, .reset_n, .rawInput(kphit), .debouncedInput(kphit_debounced));

  always_ff@(posedge clk) begin
    if(current_state == game_1)  begin
        if ({1'b0, kpNum} == game_one_bits[19:15])
          game_one_counter <= game_one_counter + 1;
         else 
          game_one_counter <= game_one_counter;
    end else
        game_one_counter <= 0;
    
  end   
//************************ mo game ***********************8


// Used to drive the 7-segs
 	 always_ff @(posedge clk) begin
		delayCnt <= delayCnt + 1'b1;  
 
    if (delayCnt == 0)
      if (digit >= 3)
        digit <= '0;
      else
        digit <= digit + 1'b1 ;

		if (kphit_debounced == 1)
			ctTemp =  1'b1;
		else
			ctTemp =  1'b0;//
	end


//Strings to be sent to the processor based on current state
	logic [31:0] start_string;
	logic [31:0] game_1_string; // james game
	logic [31:0] game_2_string; // mo game
	logic [31:0] game_3_string; // clint
	logic	[31:0] harder_string;
	logic [31:0] victory_string;

	logic [3:0] x_pos;
	logic [3:0] y_pos;
	
	assign x_pos = (adc_x_value > 12'h800) ? 4'b1111 : 4'b0000; //check for quadrant
	assign y_pos = (adc_y_value > 12'h800) ? 4'b1111 : 4'b0000;
	
	assign start_string 		= { 28'b0, 3'b00, rgb_output[0]};
	assign game_1_string		= {  4'b0, x_pos, 4'b0, y_pos, 12'b0, 3'b001, rgb_output[0]};
	assign game_2_string		= { 28'b0, 3'b010, rgb_output[0]};
	assign game_3_string		= { 28'b0, 3'b011, rgb_output[0]};
	assign harder_string		= { 28'b0, 3'b100, rgb_output[0]}; 
	assign victory_string	= { 28'hbadc0c0, 3'b101, rgb_output[0]};

  // State Variables
  logic [2:0] current_state;
  logic [2:0] next_state;  

  //emable signals for the games
  logic game_1_en, game_2_en, game_3_en, game_4_en;
  assign game_1_en = current_state == game_1 ?  1 : 0;
  assign game_2_en = current_state == game_2 ?  1 : 0;
  assign game_3_en = current_state == game_3 ?  1 : 0;
  assign game_4_en = current_state == harder ?  1 : 0;

  logic start_flag;
  assign start_flag = (kpNum == 4'hb) ? 1 : 0;

  // System States
  localparam [2:0]
    start_up  = 0,
    game_1    = 1,
    game_2    = 2,
    game_3    = 3,
	  harder	  = 4,
    victory   = 5,
    fubar     = 7; //error state if anything bad happens 
  
	assign GPIO_1[3] = current_state == victory ? 0 : 1;
  
	always_comb begin : state_logic
    unique case (current_state)  
      start_up  : begin

							rgb_input <= start_string;
						  current_state <= next_state;
              disp_num_0 <= 16;
              disp_num_1 <= 16;
              disp_num_2 <= 16;
              disp_num_3 <= 16;
              ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed
              
						  
                  end
						
      game_1    : begin // Mo game
				  rgb_input <= game_1_string;
				  current_state <= next_state;
              disp_num_0 <=  game_one_bits[19:15];
              disp_num_1 <=  game_one_bits[14:10] ;
              disp_num_2 <=  game_one_bits[9:5] ;
              disp_num_3 <=  {1'b0, kpNum} ;
					 ct =  ctTemp << digit; //Channel_gate is used to verify that only the desired channel is being displayed 
		

						      end
							
      game_2    :	begin // james Game
					
					rgb_input <= game_2_string;
					current_state <= next_state;
              disp_num_0 <= r_num_3;
              disp_num_1 <= r_num_2;
              disp_num_2 <= r_num_1;
              disp_num_3 <= r_num_0;
              ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed

              //Mo's game has different condition to drive the screen
						    end
						
      game_3    :	begin
							rgb_input <= game_3_string;
						  current_state <= next_state;   
              disp_num_0 <= 16;
              disp_num_1 <= 16;
              disp_num_2 <= 16;
              disp_num_3 <= 16;
              ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed

							  end
		harder	: begin
							rgb_input <= harder_string;
							current_state <= next_state;
              disp_num_0 <= 16;
              disp_num_1 <= 16;
              disp_num_2 <= 16;
              disp_num_3 <= 16;
              ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed
							end
						
      victory   :	begin  
							rgb_input <= victory_string;
						  current_state <= next_state;
              disp_num_0 <= 16;
              disp_num_1 <= 16;
              disp_num_2 <= 16;
              disp_num_3 <= 16; 
              ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed 
								end
      
      default : begin
        rgb_input <= 32'hbadc0c0a;
        current_state <= next_state;
        ct <=  (1'b1) << digit; //Channel_gate is used to verify that only the desired channel is being displayed
        disp_num_0 <= 16;
        disp_num_1 <= 16;
        disp_num_2 <= 16;
        disp_num_3 <= 16; 
      end
      
    endcase
  end : state_logic

  //in debug mode so a keypress will move to the next state
  always_ff @( posedge clk, negedge reset_n ) begin : state_handler
    if(~reset_n)
      next_state <= start_up;
    else begin
      case (current_state)

        start_up  : next_state = (start_flag)  ? game_1 : current_state;

        game_1    : next_state = (mo_flag) ? game_2 : current_state;

        game_2    : next_state = (james_flag) ? game_3 : current_state;

        game_3    : next_state = (~emag_state_flag ) ? harder : current_state;
		  
		   harder		: next_state = (~emag_state_flag_2) ? victory : current_state;
        
        victory   : next_state = (~reset_n) ? start_up : current_state;
       
        default: begin
          next_state <= start_up;
        end
      endcase
    end
  end : state_handler
   
endmodule


// megafunction wizard: %ALTPLL%
// ...
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
// ...

module pll ( inclk0, c0);

        input     inclk0;
        output    c0;

        wire [0:0] sub_wire2 = 1'h0;
        wire [4:0] sub_wire3;
        wire  sub_wire0 = inclk0;
        wire [1:0] sub_wire1 = {sub_wire2, sub_wire0};
        wire [0:0] sub_wire4 = sub_wire3[0:0];
        wire  c0 = sub_wire4;

        altpll altpll_component ( .inclk (sub_wire1), .clk
          (sub_wire3), .activeclock (), .areset (1'b0), .clkbad
          (), .clkena ({6{1'b1}}), .clkloss (), .clkswitch
          (1'b0), .configupdate (1'b0), .enable0 (), .enable1 (),
          .extclk (), .extclkena ({4{1'b1}}), .fbin (1'b1),
          .fbmimicbidir (), .fbout (), .fref (), .icdrclk (),
          .locked (), .pfdena (1'b1), .phasecounterselect
          ({4{1'b1}}), .phasedone (), .phasestep (1'b1),
          .phaseupdown (1'b1), .pllena (1'b1), .scanaclr (1'b0),
          .scanclk (1'b0), .scanclkena (1'b1), .scandata (1'b0),
          .scandataout (), .scandone (), .scanread (1'b0),
          .scanwrite (1'b0), .sclkout0 (), .sclkout1 (),
          .vcooverrange (), .vcounderrange ());

        defparam
                altpll_component.bandwidth_type = "AUTO",
                altpll_component.clk0_divide_by = 25000,
                altpll_component.clk0_duty_cycle = 50,
                altpll_component.clk0_multiply_by = 1,
                altpll_component.clk0_phase_shift = "0",
                altpll_component.compensate_clock = "CLK0",
                altpll_component.inclk0_input_frequency = 20000,
                altpll_component.intended_device_family = "Cyclone IV E",
                altpll_component.lpm_hint = "CBX_MODULE_PREFIX=lab1clk",
                altpll_component.lpm_type = "altpll",
                altpll_component.operation_mode = "NORMAL",
                altpll_component.pll_type = "AUTO",
                altpll_component.port_activeclock = "PORT_UNUSED",
                altpll_component.port_areset = "PORT_UNUSED",
                altpll_component.port_clkbad0 = "PORT_UNUSED",
                altpll_component.port_clkbad1 = "PORT_UNUSED",
                altpll_component.port_clkloss = "PORT_UNUSED",
                altpll_component.port_clkswitch = "PORT_UNUSED",
                altpll_component.port_configupdate = "PORT_UNUSED",
                altpll_component.port_fbin = "PORT_UNUSED",
                altpll_component.port_inclk0 = "PORT_USED",
                altpll_component.port_inclk1 = "PORT_UNUSED",
                altpll_component.port_locked = "PORT_UNUSED",
                altpll_component.port_pfdena = "PORT_UNUSED",
                altpll_component.port_phasecounterselect = "PORT_UNUSED",
                altpll_component.port_phasedone = "PORT_UNUSED",
                altpll_component.port_phasestep = "PORT_UNUSED",
                altpll_component.port_phaseupdown = "PORT_UNUSED",
                altpll_component.port_pllena = "PORT_UNUSED",
                altpll_component.port_scanaclr = "PORT_UNUSED",
                altpll_component.port_scanclk = "PORT_UNUSED",
                altpll_component.port_scanclkena = "PORT_UNUSED",
                altpll_component.port_scandata = "PORT_UNUSED",
                altpll_component.port_scandataout = "PORT_UNUSED",
                altpll_component.port_scandone = "PORT_UNUSED",
                altpll_component.port_scanread = "PORT_UNUSED",
                altpll_component.port_scanwrite = "PORT_UNUSED",
                altpll_component.port_clk0 = "PORT_USED",
                altpll_component.port_clk1 = "PORT_UNUSED",
                altpll_component.port_clk2 = "PORT_UNUSED",
                altpll_component.port_clk3 = "PORT_UNUSED",
                altpll_component.port_clk4 = "PORT_UNUSED",
                altpll_component.port_clk5 = "PORT_UNUSED",
                altpll_component.port_clkena0 = "PORT_UNUSED",
                altpll_component.port_clkena1 = "PORT_UNUSED",
                altpll_component.port_clkena2 = "PORT_UNUSED",
                altpll_component.port_clkena3 = "PORT_UNUSED",
                altpll_component.port_clkena4 = "PORT_UNUSED",
                altpll_component.port_clkena5 = "PORT_UNUSED",
                altpll_component.port_extclk0 = "PORT_UNUSED",
                altpll_component.port_extclk1 = "PORT_UNUSED",
                altpll_component.port_extclk2 = "PORT_UNUSED",
                altpll_component.port_extclk3 = "PORT_UNUSED",
                altpll_component.width_clock = 5;


endmodule

