module DE10_LITE_button_controller(
    input clk,
    input reset,
    input b1_press,
    input b2_press,

    output b1_out,
    output b2_out
);

wire b1_aux;
wire b2_aux;


`define SCHMITTRIG_DEBOUNCE
//`define DEBOUNCE_SLOWCK
//`define DEBOUNCE_DN
//`define DEBOUNCE_COUNTER
//`define DE10_LITE_button_debouncer


`ifdef SCHMITTRIG_DEBOUNCE
negedge_detect edge_pulse_b1(
    .clk(clk),
    .reset(reset),
    .data_i(b1_press),
    .pulse_o(b1_out)
);

negedge_detect edge_pulse_b2(
    .clk(clk),
    .reset(reset),
    .data_i(b2_press),
    .pulse_o(b2_out)
);
`endif 


`ifdef DEBOUNCE_SLOWCK
debounce debounce_b1(
    .inclk(clk),
    .b_in(b1_press),
    .b_out(b1_out)
);

debounce debounce_b2(
    .inclk(clk),
    .b_in(b2_press),
    .b_out(b2_out)
);
`endif

`ifdef DEBOUNCE_DN
debounce_dn debounce_b1(
    .clk(clk),
    .rst_n(reset),
    .data_i(b1_press),
    .data_o(b1_out)
);

debounce_dn debounce_b2(
    .clk(clk),
    .rst_n(reset),
    .data_i(b2_press),
    .data_o(b2_out)
);
`endif

`ifdef DEBOUNCE_COUNTER
debounce_counter debounce_b1(
    .clk(clk),
    .b_press(b1_press),
    .b_down(b1_out)
);

debounce_counter debounce_b2(
    .clk(clk),
    .b_press(b2_press),
    .b_down(b2_out)
);
`endif 

`ifdef DE10_LITE_button_debouncer
button_debouncer debounce_b1(
    .clk(clk),
    .rst(reset),
    .data_in(b1_press),
    .data_out(b1_out)
);

button_debouncer debounce_b2(
    .clk(clk),
    .rst(reset),
    .data_in(b2_press),
    .data_out(b2_out)
);

`endif 

endmodule