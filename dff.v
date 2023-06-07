module d_ff(
    input inclk,
    input D,
    output reg Q,
    output reg Q_n
);

always@(posedge inclk) begin
    Q <= D;
    Q_n <= !Q;
end

endmodule