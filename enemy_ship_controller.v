module enemy_ship_controller(
    input clk,
    input reset,
    input b1_press,
    input b2_press,
    input [9:0] player_x,

    output [9:0] enemy_A_x,
    output [8:0] enemy_A_y,

    output [9:0] enemy_B_x,
    output [8:0] enemy_B_y,

    output [9:0] enemy_C_x,
    output [8:0] enemy_C_y
    );

    parameter MAX_BP = 5;
    parameter DEFAULT_SPAWN = 3'b010;

    wire A_on_screen;
    wire B_on_screen;
    wire C_on_screen;

    reg [2:0] spawn_pos;

    //reg enable;
    reg spawn_enable_A;
    reg spawn_enable_B;
    reg spawn_enable_C;

    wire button_press = (b1_press || b2_press);
    reg [3:0] counter;
    always @(posedge clk) begin
        if(reset) begin
            counter <= 0;
        end
        else begin
            if(button_press) begin
                if(counter == MAX_BP) begin
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end                
            end
        end
    end

    always @(posedge clk) begin
        if(reset) begin
            spawn_pos <= DEFAULT_SPAWN;
        end
        else begin
            if(spawn_pos == 3'b000) begin
                spawn_pos <= DEFAULT_SPAWN;
            end
            else begin
                if(b1_press) begin
                    spawn_pos <= spawn_pos / 2;
                end
                else begin
                    if(b2_press) begin
                        spawn_pos <= spawn_pos * 2;
                    end
                end
            end
        end
    end

    reg [5:0] state;
    parameter IDL = 0;
    parameter WAIT = 1;
    parameter CHECK_SPAWN_POS = 2;
    parameter CHECK_SPAWN_A = 3;
    parameter CHECK_SPAWN_B = 4;
    parameter CHECK_SPAWN_C = 5;
    parameter SPAWN_A = 6;
    parameter SPAWN_B = 7;
    parameter SPAWN_C = 8;

    always @(posedge clk) begin
        case(state)
            IDL: begin
                if(reset) begin
                    state <= WAIT;
                end
            end

            WAIT: begin
                spawn_enable_A <= 0;
                spawn_enable_B <= 0;
                spawn_enable_C <= 0;
                if(counter == MAX_BP) begin
                    state <= CHECK_SPAWN_POS;
                end
            end

           CHECK_SPAWN_POS: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    case(spawn_pos)
                        3'b001: state <= CHECK_SPAWN_A;
                        3'b010: state <= CHECK_SPAWN_B;
                        3'b100: state <= CHECK_SPAWN_C;
                    endcase
                end
           end

           CHECK_SPAWN_A: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    if(!A_on_screen) begin
                        state <= SPAWN_A;
                    end
                    else begin
                        state <= WAIT;
                    end
                end
           end

           CHECK_SPAWN_B: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    if(!B_on_screen) begin
                        state <= SPAWN_B;
                    end
                    else begin
                        state <= WAIT;
                    end
                end
           end

           CHECK_SPAWN_C: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    if(!C_on_screen) begin
                        state <= SPAWN_C;
                    end
                    else begin
                        state <= WAIT;
                    end
                end
           end

           SPAWN_A: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    spawn_enable_A = 1;
                    state <= WAIT;
                end
           end

           SPAWN_B: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    spawn_enable_B = 1;
                    state <= WAIT;
                end
           end

           SPAWN_C: begin
                if(reset) begin
                    state <= WAIT;
                end
                else begin
                    spawn_enable_C = 1;
                    state <= WAIT;
                end
           end
        endcase
    end
    

    enemy_ship #(.x_init(200)) shipA (
        .clk(clk),
        .reset(reset),
        .spawn_enable(spawn_enable_A),
        .player_x(player_x),
        .enemy_x(enemy_A_x),
        .enemy_y(enemy_A_y),
        .on_screen(A_on_screen)
    );

    enemy_ship #(.x_init(240)) ship_B(
        .clk(clk),
        .reset(reset),
        .spawn_enable(spawn_enable_B),
        .player_x(player_x),
        .enemy_x(enemy_B_x),
        .enemy_y(enemy_B_y),
        .on_screen(B_on_screen)
    );

    enemy_ship #(.x_init(280)) ship_C(
        .clk(clk),
        .reset(reset),
        .spawn_enable(spawn_enable_C),
        .player_x(player_x),
        .enemy_x(enemy_C_x),
        .enemy_y(enemy_C_y),
        .on_screen(C_on_screen)
    );

endmodule