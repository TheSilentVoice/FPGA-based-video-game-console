module debounce(
    input inclk,
    input b_in,
    output b_out
);

wire slowclk;
wire Q_1;
wire Q_2;
wire Q_2_n;

slow_clock to_4Hz_clkgen(
    .inclk(inclk),
    .slow_clock(slowclk)
);

d_ff dff_1(
    .inclk(slowclk),
    .D(b_in),
    .Q(Q_1)
);

d_ff dff_2(
    .inclk(slowclk),
    .D(Q_1),
    .Q(Q_2)
);

assign Q_2_n = ~ Q_2;
assign b_out = (Q_1 & Q_2_n);

endmodule