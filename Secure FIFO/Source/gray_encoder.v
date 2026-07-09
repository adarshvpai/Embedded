`timescale 1ns/1ps
module gray_encoder (
    input  [3:0] bin,
    output [3:0] gray
);
    assign gray = (bin >> 1) ^ bin;
endmodule