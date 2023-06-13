///////Improvement: add both negedge and posedge////
module negedge_detect(
    input clk,
    input reset, 
    input data_i,

    output pulse_o
);

reg data_delay;

always@(posedge clk) begin
    if(reset) begin
        data_delay <= 0;
    end else begin
        data_delay <= data_i;
    end
end

assign pulse_o = (~data_i) & data_delay;
endmodule