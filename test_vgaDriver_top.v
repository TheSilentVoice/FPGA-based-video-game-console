`include "seven_segment.v"
`include "digit_bitmap.v"

module test_vgaDriver_top(
    input VGA_IN_CLK,
    
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


wire [9:0] vpos;
wire [8:0] hpos;
reg [15:0] VGA_RGB_IN;

reg reset;
reg reset_lock;

always@(posedge VGA_IN_CLK) begin
    if(reset_lock) begin
        reset <= 0;
    end 
    else begin
        reset <= 1;
        reset_lock <= 1;
    end
end

//PATTERN GENERATOR
//--------------------------------------------------------------------
//always@(hpos || vpos) begin
//    if((hpos&7)==0|| (vpos&7)==0) begin
//        VGA_RGB_IN = RED;
//    end 
//    else begin
//        if(hpos[4]) begin
//            VGA_RGB_IN = GREEN;
//        end 
//        else begin
//            if(vpos[4]) begin
//                VGA_RGB_IN = BLUE;
//            end 
//            else begin
//                VGA_RGB_IN = BLACK;
//            end
//        end
//    end
//end
//--------------------------------------------------------------------


reg signed [8:0] ball_hpos;
reg signed [8:0] ball_vpos;

reg signed [8:0] ball_horiz_move = -2;
reg signed [8:0] ball_vert_move = 2;

localparam hinit = 128;
localparam vinit = 128;
localparam size = 4;

wire [8:0] ball_hdiff = hpos - ball_hpos;
wire [8:0] ball_vdiff = vpos - ball_vpos;

wire ball_hgfx = ball_hpos == hpos;
wire ball_vgfx = ball_vpos == vpos;
wire ball_gfx = ball_hgfx && ball_vgfx;





always @(posedge VGA_VSYNC or posedge reset) begin
    if (reset) begin
        ball_hpos <= hinit;
        ball_vpos <= vinit;
    end 
    else begin
        ball_hpos <= ball_hpos + ball_horiz_move;
        ball_vpos <= ball_vpos + ball_vert_move;
    end
end




wire ball_horiz_collide = ball_hpos >= 640;
wire ball_vert_collide  = ball_vpos >= 480;

always @(posedge ball_vert_collide) begin
    ball_vert_move <= -ball_vert_move;
end

always @(posedge ball_horiz_collide) begin
    ball_horiz_move <= -ball_horiz_move;
end


always@(*) begin
    if (ball_hgfx | ball_gfx) begin
        VGA_RGB_IN <= BLUE;
    end
    else begin
        if (ball_vgfx | ball_gfx) begin
            VGA_RGB_IN <= RED;
        end
        else begin
            VGA_RGB_IN <= BLACK;
        end
    end

    if(ball_gfx)
        VGA_RGB_IN <= WHITE;
end
    

vgaDriver driver(
    .clk_i(VGA_IN_CLK),
    .reset_i(reset),
    .rgb_i(VGA_RGB_IN),
    .red_o(VGA_RED_O),
    .green_o(VGA_GREEN_O),
    .blue_o(VGA_BLUE_O),
    .hSync_o(VGA_HSYNC),
    .vSync_o(VGA_VSYNC),
    .row_o(hpos),
    .column_o(vpos)
);


endmodule