module read_controller (
    input rd_clk,
    input rst_n,
    input rd_en,
    input empty,
    output reg [3:0] rd_bin,
    output [3:0] rd_gray
);

    gray_encoder GE_RD (
        .bin(rd_bin),
        .gray(rd_gray)
    );

    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n)
            rd_bin <= 4'b0000;
        else if (rd_en && !empty)
            rd_bin <= rd_bin + 1'b1;
    end

endmodule