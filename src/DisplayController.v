module DisplayController(
	input en, 

	output [4:0] map_x, 
	output [4:0] map_y, 
	input [2:0] sprite_type, 

	input pacman_orientation,
	output [2:0] character_type, 
	input [7:0] char_x,
	input [7:0] char_y,

	output reg vga_plot, 
	output reg [7:0] vga_x,
	output reg [7:0] vga_y,
	output reg [2:0] vga_color,

	input reset, 
	input clock_50,
	output [7:0] debug_leds
	);
	
	// A clock, used to determine which display controller to use.
    reg selected_display_controller;
    reg [14:0] current_time;
    always @(posedge clock_50)
    begin
    	if (reset == 1'b1)
    	begin
    		current_time <= 14'd0;
    		selected_display_controller <= 1'b0;
    	end
    	else 
    	begin
    		if (current_time < 14'd11050)
    		begin
    			current_time <= current_time + 14'd1;
    			selected_display_controller <= 1'b0;
    		end
    		else if (current_time >= 14'd11050 && current_time < 14'd11100)
    		begin
    			current_time <= current_time + 14'd1;
    			selected_display_controller <= 1'b1;
    		end
    		else 
    		begin
    			current_time <= 14'd0;
    			selected_display_controller <= 1'b0;    			
    		end
    	end    	
    end

    // The VGA output pins from the various controllers.
    wire [7:0] vga_x_cdc;
    wire [7:0] vga_y_cdc;
    wire [7:0] vga_x_mdc;
    wire [7:0] vga_y_mdc;
	wire [2:0] vga_color_cdc;
	wire [2:0] vga_color_mdc;
	wire vga_plot_cdc;
	wire vga_plot_mdc;

	CharacterDisplayController cdc_controller(
		.en(en),
		.pacman_orientation(pacman_orientation),
		.character_type(character_type),
		.char_x(char_x),
		.char_y(char_y),
		.vga_plot(vga_plot_cdc),
		.vga_x(vga_x_cdc),
		.vga_y(vga_y_cdc),
		.vga_color(vga_color_cdc),
		.reset(reset),
		.clock_50(clock_50)
	);

	MapDisplayController mdc_controller(
		.en(en), 
		.map_x(map_x), 
		.map_y(map_y), 
		.sprite_type(sprite_type), 
		.vga_plot(vga_plot_mdc), 
		.vga_x(vga_x_mdc), 
		.vga_y(vga_y_mdc), 
		.vga_color(vga_color_mdc),
		.reset(reset), 
		.clock_50(clock_50), 
		.debug_leds(debug_leds)
	);

	// The mux, used to select which vga pins to use
	always @(*)
	begin
		if (selected_display_controller == 1'b0)
		begin
			vga_x = vga_x_mdc;
			vga_y = vga_y_mdc;
			vga_color = vga_color_mdc;
			vga_plot = vga_plot_mdc;	
		end
		else 
		begin
			vga_x = vga_x_cdc;
			vga_y = vga_y_cdc;
			vga_color = vga_color_cdc;
			vga_plot = vga_plot_cdc;	
		end
	end

endmodule