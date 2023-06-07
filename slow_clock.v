module slow_clock(
   input inclk,
   output reg slow_clock
);

reg [23:0] count = 0;

always@(posedge inclk) begin
   count <= count + 1;
   if(count == 6_250_000) begin 
     count <= 0;
     slow_clock <= ~slow_clock;
   end
end

endmodule       