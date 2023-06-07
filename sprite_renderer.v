module sprite_renderer(
    input clk, 
    input vstart, 
    input load, 
    input hstart, 
    output reg [3:0] rom_addr, 
    input [7:0] rom_bits, 
    output reg gfx, 
    output inloop);


//STATES
localparam WAIT_FOR_VSTART = 0;
localparam WAIT_FOR_LOAD   = 1;
localparam LOAD_SETUP      = 2;
localparam LOAD_FETCH      = 3;
localparam WAIT_FOR_HSTART = 4;
localparam DRAW            = 5;

reg [2:0] state;
reg [3:0] ycount;
reg [3:0] xcount;
reg [7:0] outbits;

assign inloop = state == !WAIT_FOR_VSTART;

always @(posedge clk) begin
    case (state) 
        WAIT_FOR_VSTART: begin
            ycount <= 0;
            gfx <= 0;

            if(vstart) begin
                state <= WAIT_FOR_LOAD;
            end
        end

        WAIT_FOR_LOAD: begin 
            xcount <= 0;
            gfx <= 0;

            if(load) begin
                state <= LOAD_SETUP;
            end
        end

        LOAD_SETUP: begin
            rom_addr <= ycount;
            state <= LOAD_FETCH;
        end

        LOAD_FETCH: begin
            outbits <= rom_bits;
            state <= WAIT_FOR_HSTART;
        end

        WAIT_FOR_HSTART: begin
            if(hstart) begin
                state <= DRAW;
            end
        end

        DRAW: begin
            gfx <= outbits[xcount<8 ? xcount[2:0] : ~xcount[2:0]];
            xcount <= xcount + 1;

            if(xcount == 15) begin
                ycount <= ycount + 1;

                if(ycount == 15) begin
                    state <= WAIT_FOR_VSTART;
                end else begin
                    state <= WAIT_FOR_LOAD;
                end
            end
        end

        default: begin
            state <= WAIT_FOR_VSTART;
        end
    endcase
end
endmodule