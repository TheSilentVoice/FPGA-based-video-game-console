module enemy_ship(
    input clk,
    input reset,
    //input enable,
    input spawn_enable,
    input [9:0] player_x,

    output reg [9:0] enemy_x,
    output reg [8:0] enemy_y,
    output reg on_screen
);

parameter x_init = 240;
parameter y_init =  50;

wire spawn_enemy;
wire tracker = player_x < 240;
reg [2:0] spawn_pos;

reg [3:0] state ;
parameter IDL     = 0;
parameter SPAWN   = 1;
parameter TRACK   = 2;
parameter DESPAWN = 3;


always @(posedge clk) begin
    case (state)
        IDL: begin
            if(reset) begin
                state <= IDL;
            end 
            else begin
                if(spawn_enable) begin
                    state <= SPAWN;
                end
            end
        end

        SPAWN: begin 
            if(reset) begin
                state <= IDL;
            end
            else begin
                    on_screen <= 1;
                    enemy_x <= x_init;
                    enemy_y <= y_init;
                    state <= TRACK;
            end
        end

        TRACK: begin
            if(reset) begin
                state <= IDL;
            end
            else begin
                enemy_y <= enemy_y + 10;
                if(tracker) begin
                    enemy_x <= enemy_x - 15;
                end
                else begin
                    enemy_x <= enemy_x + 15;
                end

                if(enemy_y >= 420) begin
                    state <= DESPAWN;
                end
                else begin
                    state <= TRACK;
                end
            end
        end

        DESPAWN: begin
            if(reset) begin
                state <= IDL;
            end 
            else begin
                on_screen <= 0;
                state <= IDL;
            end
        end

        default: state <= IDL;
    endcase
end
endmodule