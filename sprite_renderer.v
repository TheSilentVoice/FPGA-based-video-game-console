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

parameter initial_x = 240;
parameter initial_y = 400;


wire mv_left, mv_right;
parameter mvspeed = 15;

wire [8:0] ypos;
wire [9:0] xpos;
reg [15:0] VGA_RGB_IN;


wire [3:0] player_ship_sprite_addr;
wire [7:0] player_ship_sprite_bits;

wire [3:0] enemyA_ship_sprite_addr;
wire [7:0] enemyA_ship_sprite_bits;
wire [3:0] enemyB_ship_sprite_addr;
wire [7:0] enemyB_ship_sprite_bits;
wire [3:0] enemyC_ship_sprite_addr;
wire [7:0] enemyC_ship_sprite_bits;

reg [8:0] draw_pos_y;
reg [9:0] draw_pos_x;

wire [8:0] enemyA_draw_pos_y;
wire [9:0] enemyA_draw_pos_x;
wire [8:0] enemyB_draw_pos_y;
wire [9:0] enemyB_draw_pos_x;
wire [8:0] enemyC_draw_pos_y;
wire [9:0] enemyC_draw_pos_x;

wire left_barrier_touch = draw_pos_x <= 160;
wire right_barrier_touch = draw_pos_x >= 320;

wire vstart = draw_pos_y == ypos;
wire hstart = draw_pos_x == xpos;
wire player_gfx;
wire enemy_A_gfx;
wire enemy_B_gfx;
wire enemy_C_gfx;

wire player_inloop;
wire enemy_A_inloop;
wire enemy_B_inloop;
wire enemy_C_inloop;



wire vstart_A = enemyA_draw_pos_y == ypos;
wire hstart_A = enemyA_draw_pos_x == xpos;
wire vstart_B = enemyB_draw_pos_y == ypos;
wire hstart_B = enemyB_draw_pos_x == xpos;
wire vstart_C = enemyC_draw_pos_y == ypos;
wire hstart_C = enemyC_draw_pos_x == xpos;


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
    if(player_gfx) begin
        VGA_RGB_IN <= CYAN;
    end
    else begin
            VGA_RGB_IN <= BLACK;    
    end

    if(enemy_A_gfx) begin
        VGA_RGB_IN <= GREEN;
    end
    else begin
            VGA_RGB_IN <= BLACK;    
    end

    if(enemy_B_gfx) begin
        VGA_RGB_IN <= GREEN;
    end
    else begin
            VGA_RGB_IN <= BLACK;    
    end

    if(enemy_C_gfx) begin
        VGA_RGB_IN <= GREEN;
    end
    else begin
            VGA_RGB_IN <= BLACK;    
    end

   
end



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

sprite_renderer player(
    .clk(SYS_CLK),
    .vstart(vstart),
    .load(VGA_HSYNC),
    .hstart(hstart),
    .rom_addr(player_ship_sprite_addr),
    .rom_bits(player_ship_sprite_bits),
    .gfx(gfx),
    .inloop(inloop)
);

sprite_renderer enemy_A(
    .clk(SYS_CLK),
    .vstart(vstart_A),
    .load(VGA_HSYNC),
    .hstart(hstart_A),
    .rom_addr(enemyA_ship_sprite_addr),
    .rom_bits(enemyA_ship_sprite_bits),
    .gfx(enemy_A_gfx),
    .inloop(enemy_A_inloop)
);

sprite_renderer enemy_B(
    .clk(SYS_CLK),
    .vstart(vstart_B),
    .load(VGA_HSYNC),
    .hstart(hstart_B),
    .rom_addr(enemyB_ship_sprite_addr),
    .rom_bits(enemyB_ship_sprite_bits),
    .gfx(enemy_B_gfx),
    .inloop(enemy_A_inloop)
);

sprite_renderer enemy_C(
    .clk(SYS_CLK),
    .vstart(vstart_C),
    .load(VGA_HSYNC),
    .hstart(hstart_C),
    .rom_addr(enemyC_ship_sprite_addr),
    .rom_bits(enemyC_ship_sprite_bits),
    .gfx(enemy_C_gfx),
    .inloop(enemy_C_inloop)
);

enemy_ship_controller enemy_ships(
    .clk(clk),
    .reset(reset),
    .b1_press(b1_press),
    .b2_press(b2_press),
    .player_x(draw_pos_x),
    .enemy_A_x(enemyA_draw_pos_x),
    .enemy_A_y(enemyA_draw_pos_y),
    .enemy_B_x(enemyB_draw_pos_x),
    .enemy_B_y(enemyB_draw_pos_y),
    .enemy_C_x(enemyC_draw_pos_x),
    .enemy_C_y(enemyC_draw_pos_y),

);