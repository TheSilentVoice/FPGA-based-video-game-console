module test_vgaDriver_top(
    input SYS_CLK,
    
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

reg [15:0] ball_horiz_move = -2;
reg [15:0] ball_vert_move = 2;

localparam hinit = 128;
localparam vinit = 128;
localparam size = 4;

wire [15:0] vpos;
wire [15:0] hpos;
reg [15:0] VGA_RGB_IN;

reg [15:0] ball_hpos;
reg [15:0] ball_vpos;
//ire [15:0] ball_hdiff = (hpos - ball_hpos);
//wire [15:0] ball_vdiff = (vpos - ball_vpos);

wire ball_gfx = (ball_hpos == hpos) && (ball_vpos == vpos);

wire ball_horiz_collide = ball_hpos >= 640;
wire ball_vert_collide  = ball_vpos >= 480;

reg reset;
reg reset_lock;
always@(posedge SYS_CLK) begin
    if(reset_lock) begin
        reset <= 0;
    end 
    else begin
        reset <= 1;
        reset_lock <= 1;
    end
end

always@(posedge SYS_CLK) begin
    if(reset) begin
        ball_hpos <= hinit;
    end
    else begin
        if(VGA_VSYNC) begin
            ball_hpos <= ball_hpos + ball_horiz_move;
        end
        else begin
            if(ball_horiz_collide) begin
                ball_horiz_move <= -ball_horiz_move;
            end
        end
    end
end

always@(posedge SYS_CLK) begin
    if(reset) begin
        ball_vpos <= vinit;
    end
    else begin
        if(VGA_VSYNC) begin
            ball_vpos <= ball_vpos + ball_vert_move;
        end
        else begin
            if(ball_vert_collide) begin
                ball_vert_move <= -ball_vert_move;
            end
        end
    end
end

always@(posedge SYS_CLK) begin
    if(ball_gfx) begin
        VGA_RGB_IN <= WHITE;
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
    .row_o(vpos),
    .column_o(hpos)
);

endmodule