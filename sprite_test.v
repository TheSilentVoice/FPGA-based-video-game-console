module sprite_test(
    input SYS_CLK,
    input reset,

    input b1_press,
    input b2_press,

    output  [3:0] VGA_RED_O,
    output  [3:0] VGA_GREEN_O,
    output  [3:0] VGA_BLUE_O,
    output  VGA_HSYNC,
    output  VGA_VSYNC
);

parameter RED     = 16'hF000;
parameter GREEN   = 16'h7E0;
parameter BLUE    = 16'h1F;
parameter YELLOW  = 16'hFFE0;
parameter MAGENTA = 16'hF81F;
parameter CYAN    = 16'h7FF;
parameter BLACK   = 16'h0;
parameter WHITE   = 16'hFFFF;

parameter initial_x = 256;
parameter initial_y = 256;


wire mv_left, mv_right;
parameter mvspeed = 1;

wire [8:0] ypos;
wire [9:0] xpos;
reg [15:0] VGA_RGB_IN;


wire [3:0] car_sprite_addr;
wire [7:0] car_sprite_bits;

reg [8:0] draw_pos_y;
reg [9:0] draw_pos_x;



wire vstart = draw_pos_y == ypos;
wire hstart = draw_pos_x == xpos;
wire gfx;
wire inloop;



always @(SYS_CLK) begin
    if(reset) begin
        draw_pos_x <= initial_x;
        draw_pos_y <= initial_y;
    end else begin 
            if(mv_left && draw_pos_x >= 100) begin
                    draw_pos_x <= draw_pos_x - mvspeed;
            end 
            else begin
            if(mv_right && draw_pos_x <= 400) begin
                    draw_pos_x <= draw_pos_x + mvspeed;
            end
            end
        end
end



always @(SYS_CLK) begin
    if(gfx) begin
        VGA_RGB_IN <= WHITE;
    end
    else begin
            VGA_RGB_IN <= BLACK;    
        end
end

///////////////////////////////////////
//IMPLEMENT BUTTONS AND SWITCHES///////
///////////////////////////////////////

vgaDriver driver(
    .clk_i(SYS_CLK),
    .reset_i(reset),
    .rgb_i(VGA_RGB_IN),
    .red_o(VGA_RED_O),
    .green_o(VGA_GREEN_O),
    .blue_o(VGA_BLUE_O),
    .hSync_o(VGA_HSYNC),
    .vSync_o(VGA_VSYNC),
    .row_o(ypos),
    .column_o(xpos)
);

DE10_lite_button_controller button_controller(
    .clk(SYS_CLK),
    .b1_press(b1_press),
    .b2_press(b2_press),
    .b1_out(mv_left),
    .b2_out(mv_right)
);


car_bitmap car_sprite(
    .pos(car_sprite_addr),
    .pix(car_sprite_bits),
);

sprite_renderer renderer(
    .clk(SYS_CLK),
    .vstart(vstart),
    .load(VGA_HSYNC),
    .hstart(hstart),
    .rom_addr(car_sprite_addr),
    .rom_bits(car_sprite_bits),
    .gfx(gfx),
    .inloop(inloop)
);

endmodule