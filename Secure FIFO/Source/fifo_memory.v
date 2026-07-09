module fifo_memory (
    input wr_clk,
    input rd_clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input [7:0] data_in,
    input [3:0] wr_addr,
    input [3:0] rd_addr,
    input [3:0] wr_gray_sync,
    input [3:0] rd_gray_sync,
    output reg [7:0] data_out,
    output full,
    output empty
);

    parameter DEPTH = 16;
    reg [7:0] mem [0:DEPTH-1];

    // Write operation
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            // Optional: Clear memory
        end else if (wr_en && !full) begin
            mem[wr_addr] <= data_in;
        end
    end

    // Read operation
    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= 8'b0;
        else if (rd_en && !empty)
            data_out <= mem[rd_addr];
    end

    // Empty condition
    assign empty = (wr_gray_sync == rd_gray_sync);

    // Full condition (standard Gray code comparison)
    assign full =
        (wr_gray_sync == {~rd_gray_sync[3:2], rd_gray_sync[1:0]});

endmodule