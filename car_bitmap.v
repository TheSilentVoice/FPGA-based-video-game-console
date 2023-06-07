module car_bitmap(
    input [3:0] pos,
    output [7:0] pix
);
   
    reg [7:0] bitarray [0:15];

    assign pix = bitarray[pos];
    initial begin/*{w:8,h:16}*/
    bitarray[0] = 8'b0;
    bitarray[1] = 8'b00000001;
    bitarray[2] = 8'b00000011;
    bitarray[3] = 8'b00000111;
    bitarray[4] = 8'b00001111;
    bitarray[5] = 8'b00000011;
    bitarray[6] = 8'b00000111;
    bitarray[7] = 8'b00001111;
    bitarray[8] = 8'b00011111;
    bitarray[9] = 8'b00111111;
    bitarray[10] = 8'b11111111;
    bitarray[11] = 8'b00001111;
    bitarray[12] = 8'b00000111;
    bitarray[13] = 8'b00000111;
    bitarray[14] = 8'b00000001;
    bitarray[15] = 8'b0;
  end

endmodule