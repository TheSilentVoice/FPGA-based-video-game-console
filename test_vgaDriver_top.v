


module test_vgaDriver_top(
    input VGA_IN_CLK,
    
    output  [3:0] VGA_RED_O,
    output  [3:0] VGA_GREEN_O,
    output  [3:0] VGA_BLUE_O,
    output  VGA_HSYNC,
    output  VGA_VSYNC
);


parameter RED     =16'hF000;
parameter GREEN   =16'h7E0;
parameter BLUE    =16'h1F;
parameter YELLOW  =16'hFFE0;
parameter MAGENTA =16'hF81F;
parameter CYAN    =16'h7FF;


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

always@(hpos || vpos ) begin
    if((hpos&7)==0 || (vpos&7)==0) begin
        VGA_RGB_IN = RED;
    end 
    else begin
        if(vpos[4]) begin
            VGA_RGB_IN = GREEN;
        end 
        else begin
            if(hpos[4]) begin
                VGA_RGB_IN = BLUE;
            end
        end
    end
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