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
parameter initial_y = 400;


wire mv_left, mv_right;
parameter mvspeed = 15;

wire [8:0] ypos;
wire [9:0] xpos;
reg [15:0] VGA_RGB_IN;


wire [3:0] ship_sprite_addr;
wire [7:0] ship_sprite_bits;

reg [8:0] draw_pos_y;
reg [9:0] draw_pos_x;


wire left_barrier_touch = draw_pos_x <= 160;
wire right_barrier_touch = draw_pos_x >= 320;

wire vstart = draw_pos_y == ypos;
wire hstart = draw_pos_x == xpos;
wire gfx;
wire inloop;

reg [3:0] state;
parameter IDL  = 0;
parameter LOAD = 1;
parameter WAIT_MV = 2;
parameter ADD  = 3;
parameter SUB  = 4;

always @(posedge SYS_CLK) begin
    case (state)
        IDL: begin
            if(reset) begin
                state <= LOAD;
            end
        end

        LOAD: begin
            draw_pos_x <= initial_x;
            draw_pos_y <= initial_y;
            state <= WAIT_MV;
        end

        WAIT_MV: begin
            if(reset) begin
                state <= LOAD;
            end 
            else begin
                if(!inloop) begin
                    if(mv_left) begin
                        state <= SUB;
                    end
                    else begin
                        if(mv_right) begin
                            state <= ADD;
                        end
                    end
                end
            end
        end

        ADD: begin
            if(reset) begin
                state <= LOAD;
            end
            else begin
                if(right_barrier_touch) begin
                    draw_pos_x <= 160;
                end
                else begin
                    draw_pos_x <= draw_pos_x + mvspeed;
                end
            end

            state <= WAIT_MV;
        end

        SUB: begin
            if(reset) begin
                state <= LOAD;
            end
            else begin
                if(left_barrier_touch) begin
                    draw_pos_x <= 320;
                end 
                else begin
                    draw_pos_x <= draw_pos_x - mvspeed;    
                end
            end

            state<= WAIT_MV;
        end

        default: begin
            state <= IDL;
        end
    endcase
end

always @(SYS_CLK) begin
    if(gfx) begin
        VGA_RGB_IN <= CYAN;
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

DE10_LITE_button_controller button_controller(
    .clk(SYS_CLK),
    .b1_press(b1_press),
    .b2_press(b2_press),
    .b1_out(mv_left),
    .b2_out(mv_right)
);


ship_bitmap ship_sprite(
    .pos(ship_sprite_addr),
    .pix(ship_sprite_bits),
);

sprite_renderer renderer(
    .clk(SYS_CLK),
    .vstart(vstart),
    .load(VGA_HSYNC),
    .hstart(hstart),
    .rom_addr(ship_sprite_addr),
    .rom_bits(ship_sprite_bits),
    .gfx(gfx),
    .inloop(inloop)
);

endmodule