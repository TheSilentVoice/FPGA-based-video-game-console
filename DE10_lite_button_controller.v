module DE10_lite_button_controller(
    input clk,
    input b1_press,
    input b2_press,

    output b1_out,
    output b2_out
);

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


endmodule