`timescale 1ns/1ps
module sync_2ff (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg [3:0] q
);

    reg [3:0] q1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 4'b0000;
            q  <= 4'b0000;
        end else begin
            q1 <= d;
            q  <= q1;
        end
    end

endmodule