//============================================================
// Module: feature_extractor
// Description: Extracts behavioral features for Trojan detection
//              while avoiding false positives using system_ready.
//============================================================
module feature_extractor (
    input wr_clk,
    input rd_clk,
    input rst_n,
    input system_ready,        // Enables detection after stabilization
    input wr_en,
    input rd_en,
    input full,
    input empty,
    input [3:0] wr_bin,
    input [3:0] rd_bin,
    output illegal_write,
    output illegal_read,
    output pointer_jump
);

    reg [3:0] prev_wr_bin;
    reg [3:0] prev_rd_bin;

    // Store previous pointer values
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n)
            prev_wr_bin <= 4'b0000;
        else
            prev_wr_bin <= wr_bin;
    end

    always @(posedge rd_clk or negedge rst_n) begin
        if (!rst_n)
            prev_rd_bin <= 4'b0000;
        else
            prev_rd_bin <= rd_bin;
    end

    // Detect illegal operations only after system stabilization
    assign illegal_write = system_ready && wr_en && full;
    assign illegal_read  = system_ready && rd_en && empty;

    // Normal increment and wrap-around detection
    wire wr_normal_inc = (wr_bin == (prev_wr_bin + 1'b1));
    wire wr_wrap       = (prev_wr_bin == 4'd15 && wr_bin == 4'd0);

    wire rd_normal_inc = (rd_bin == (prev_rd_bin + 1'b1));
    wire rd_wrap       = (prev_rd_bin == 4'd15 && rd_bin == 4'd0);

    // Detect abnormal pointer jumps (Trojan behavior)
    wire wr_jump = !(wr_normal_inc || wr_wrap) && (wr_bin != prev_wr_bin);
    wire rd_jump = !(rd_normal_inc || rd_wrap) && (rd_bin != prev_rd_bin);

    assign pointer_jump = system_ready && (wr_jump || rd_jump);

endmodule