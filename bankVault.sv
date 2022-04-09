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
              
              //OLED Controls
              output logic rgb_din, rgb_clk, rgb_cs, rgb_dc, rgb_res

				 
) ;

  logic clk ;               // clock
  logic [11:0] adcValue;    // ADC result    
  logic [3:0] displayNum;	  // number to display on 7-seg
  logic [3:0] kpNum; 		    // keypad output
  logic [1:0] digit;        // 7-seg display digit currently selected
  logic [7:0] delayCnt;     // delay count to slow down digit cycling on display
  logic kphit;              // keypad button press indicator

	pll pll0 ( .inclk0(FPGA_CLK1_50), .c0(clk) ) ;

	// instantiate your modules here...
	decode7 decode7_0 (.num(displayNum), .leds) ;
	kpdecode kpdecode_0 (.kpr, .kpc, .kphit, .num(kpNum)) ;
	colseq colseq_0 (.clk, .reset_n, .kpr, .kpc);

  // ADC interface signals   
  logic [3:0] adc_chan;
  logic [11:0] adc_x_value;
  logic [11:0] adc_y_value;

  adcinterface adcinterface_X(  .clk, .reset_n,  .chan(adc_chan), .result(adcValue), .ADC_CONVST, .ADC_SCK, .ADC_SDI, .ADC_SDO);
  
  //Toggles the channel on the ADC to alternate sampling X and Y axis
  always_ff @(posedge clk ) begin

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
  assign rgb_res =  ((kpNum[3:0] == `KP_POWER) & kphit) ? 0 : 1; //Power button on kpad for reset

  // State Variables
  logic [7:0] current_state;
  logic [7:0] next_state;  

  // System States
  localparam [2:0]
    start_up  = 0,
    game_1    = 1,
    game_2    = 2,
    game_3    = 3,
    victory   = 4,
    fubar     = 7; //error state if anything bad happens

  /******************TESTING ADC********************************/
	// cycle through the three hex digits in the 12-bit ADC result displaying one at a time
    always_ff @(posedge clk) begin
	// only switch to next digit when count rolls over for crisp display
		begin
			delayCnt <= delayCnt + 1'b1;  
			if (delayCnt == 0)
				if (digit >= 2)
					digit <= '0;
				else
					digit <= digit + 1'b1 ;
		end 
	end

    // enable the 7-segment module for the selected digit

	assign ct =  (1'b1 & kphit) << digit; //Channel_gate is used to verify that only the desired channel is being displayed


    // select the bits from the 12-bit ADC result for the selected digit	
	always_comb
	case( digit )
        2 : displayNum <= rgb_input[31:28] ;
        1 : displayNum <= rgb_input[27:24] ;
        0 : displayNum <= rgb_input[23:20] ;
		default: 
           displayNum = 'hf ; 
    endcase
/******************TESTING ADC ENDS********************************/



/* State 	: Desc
	start_up : 	[31:28] 	Stability pulse
					[3:1]		State Variable
					
	
	game_1	:	[31:28]	Stability pulse
					[27:16] 	X adc
					[15:4] 	y adc
					[3:1]   state variable 
					
	game_2	: Sends Random number generated for screen display
	game_3	: Sends the spank signal
	victory 	: Sends State variable

*/
  always @* begin : state_logic
    current_state = next_sta
    unique case (current_state)  
      start_up  : begin
							rgb_output <= 
                  end
						
      game_1    : begin
							rgb_output <=
						end
						
      game_2    :	begin
							rgb_output <=
						end
						
      game_3    :	begin
							rgb_output <=
						end
						
      victory   :	begin 
							rgb_output <=
						end
      
      default : begin
        
      end
      
    endcase
  end : state_logic


  // Handles state change in reponse to state logic 
  // Currently just loops through the states
  always_ff @( posedge clk, negedge reset_n ) begin : state_handler
    if(~reset_n)
      next_state <= start_up;
    else begin

      if(current_state == (start_up && (kpNum == 1))) begin
        next_state <= game_1;
      end

      else if(current_state == (game_1 && (kpNum == 2))) begin
        next_state <= game_2;
      end      

      else if(current_state == (game_2 && (kpNum == 3))) begin
        next_state <= game_3;
      end

      else if(current_state == (game_3 && (kpNum == 4))) begin
        next_state <= victory;
      end

      else if(current_state == victory) begin
        next_state <= current_state;
      end

      else begin
        next_state <= start_up;
      end
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

