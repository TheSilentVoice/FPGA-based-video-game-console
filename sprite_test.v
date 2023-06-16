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
parameter initial_x_e = 240;
parameter initial_y_e = 50;


wire mv_left, mv_right;
parameter mvspeed = 15;

wire [8:0] ypos;
wire [9:0] xpos;
reg [15:0] VGA_RGB_IN;

wire player_load = (ypos >= 400);
wire enemy_load = (ypos >= 50) && (ypos < 400);




wire [3:0] player_ship_sprite_addr;
wire [3:0] enemy_ship_sprite_addr;
wire [3:0] ship_sprite_addr = player_load ? player_ship_sprite_addr : enemy_ship_sprite_addr;
wire [7:0] ship_sprite_bits;

reg [8:0] player_draw_pos_y;
reg [9:0] player_draw_pos_x;

reg [8:0] enemy_draw_pos_y;
reg [9:0] enemy_draw_pos_x;

wire left_barrier_touch = player_draw_pos_x <= 160;
wire right_barrier_touch = player_draw_pos_x >= 360;

wire player_vstart = player_draw_pos_y == ypos;
wire player_hstart = player_draw_pos_x == xpos;
wire enemy_vstart = enemy_draw_pos_y == ypos;
wire enemy_hstart = enemy_draw_pos_x == xpos;
wire player_gfx;
wire enemy_gfx;
wire player_inloop;
wire enemy_inloop;

wire tracker = player_draw_pos_x < 240;

//player FSM
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
            player_draw_pos_x <= initial_x;
            player_draw_pos_y <= initial_y;
            state <= WAIT_MV;
        end

        WAIT_MV: begin
            if(reset) begin
                state <= LOAD;
            end 
            else begin
                if(!player_inloop) begin
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
                    player_draw_pos_x <= 100;
                end
                else begin
                    player_draw_pos_x <= player_draw_pos_x + mvspeed;
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
                    player_draw_pos_x <= 400;
                end 
                else begin
                    player_draw_pos_x <= player_draw_pos_x - mvspeed;    
                end
            end

            state<= WAIT_MV;
        end

        default: begin
            state <= IDL;
        end
    endcase
end


//enemy FSM
reg [3:0] state_e ;
reg [3:0] counter;

reg on_screen;
parameter IDL_e       = 0;
parameter LOAD_e       = 1;
parameter WAIT_SPAWN = 2;
parameter SPAWN      = 3;
parameter TRACK      = 4;
parameter DESPAWN    = 5;
always @(posedge SYS_CLK) begin
    case (state_e)
        IDL_e: begin
            if(reset) begin
                state_e <= LOAD_e;
            end 
        end

        LOAD_e: begin
            enemy_draw_pos_x <= initial_x_e;
            enemy_draw_pos_y <= initial_y_e;
            state_e <= WAIT_SPAWN;
        end

        WAIT_SPAWN: begin
            if(mv_left | mv_right) begin
                if(!on_screen) begin
                    state_e <= SPAWN;
                end
            end
        end
        
        SPAWN: begin 
            if(reset) begin
                state_e <= LOAD_e;
            end
            else begin
                    on_screen <= 1;
                    state_e <= TRACK;
            end
        end

        TRACK: begin
            if(reset) begin
                state_e <= LOAD_e;
            end
            else begin
                if(!enemy_inloop) begin
                    if(mv_left | mv_right) begin
                        enemy_draw_pos_y <= enemy_draw_pos_y + 10;
                        if(tracker) begin
                            enemy_draw_pos_x <= enemy_draw_pos_x - mvspeed;
                        end
                        else begin
                            enemy_draw_pos_x <= enemy_draw_pos_x + mvspeed;
                        end

                        if(enemy_draw_pos_y >= 420) begin
                            state_e <= DESPAWN;
                        end
                        else begin
                            state_e <= TRACK;
                        end
                    end
                end
            end
        end

        DESPAWN: begin
            if(reset) begin
                state_e <= LOAD_e;
            end 
            else begin
                on_screen <= 0;
                state_e <= LOAD_e;
            end
        end

        default: state_e <= IDL_e;
    endcase
end


always @(SYS_CLK) begin
    if(player_gfx) begin
        VGA_RGB_IN <= CYAN;
    end
    else begin
            if(enemy_gfx) begin
                VGA_RGB_IN <= MAGENTA;
            end
            else begin
                VGA_RGB_IN <= BLACK;
            end
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

sprite_renderer player_renderer(
    .clk(SYS_CLK),
    .vstart(player_vstart),
    .load(player_load),
    .hstart(player_hstart),
    .rom_addr(player_ship_sprite_addr),
    .rom_bits(ship_sprite_bits),
    .gfx(player_gfx),
    .inloop(player_inloop)
);

sprite_renderer enemy_renderer(
    .clk(SYS_CLK),
    .vstart(enemy_vstart),
    .load(on_screen),
    .hstart(enemy_hstart),
    .rom_addr(enemy_ship_sprite_addr),
    .rom_bits(ship_sprite_bits),
    .gfx(enemy_gfx),
    .inloop(enemy_inloop)
);


endmodule