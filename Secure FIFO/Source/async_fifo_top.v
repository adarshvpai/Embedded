module async_fifo_top (
    input wr_clk,
    input rd_clk,
    input rst_n,
    input wr_en,
    input rd_en,
    input [7:0] data_in,
    output [7:0] data_out,
    output full,
    output empty,
    output trojan_alert
);

    // Internal signals
    wire [3:0] wr_bin, rd_bin;
    wire [3:0] wr_gray, rd_gray;
    wire [3:0] wr_gray_sync, rd_gray_sync;

    wire illegal_write, illegal_read, pointer_jump;
    wire rule_alert, ml_alert;

    //========================================================
    // System Ready Logic to Avoid False Positives
    //========================================================
    reg [3:0] ready_cnt;
    reg system_ready;
    
    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_cnt <= 4'd0;
            system_ready <= 1'b0;
        end else if (ready_cnt < 4'd10) begin
            ready_cnt <= ready_cnt + 1'b1;
            system_ready <= 1'b0;
        end else begin
            system_ready <= 1'b1;
        end
    end

    // Write Controller with Trojan
    write_controller WR_CTRL (
        .wr_clk(wr_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .full(full),
        .wr_bin(wr_bin),
        .wr_gray(wr_gray)
    );

    // Read Controller
    read_controller RD_CTRL (
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .rd_en(rd_en),
        .empty(empty),
        .rd_bin(rd_bin),
        .rd_gray(rd_gray)
    );

    // Synchronizers
    sync_2ff SYNC_WR_TO_RD (
        .clk(rd_clk),
        .rst_n(rst_n),
        .d(wr_gray),
        .q(wr_gray_sync)
    );

    sync_2ff SYNC_RD_TO_WR (
        .clk(wr_clk),
        .rst_n(rst_n),
        .d(rd_gray),
        .q(rd_gray_sync)
    );

    // FIFO Memory with Full/Empty Logic
    fifo_memory FIFO_MEM (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .wr_addr(wr_bin),
        .rd_addr(rd_bin),
        .wr_gray_sync(wr_gray_sync),
        .rd_gray_sync(rd_gray_sync),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    feature_extractor FE (
        .wr_clk        (wr_clk),
        .rd_clk        (rd_clk),
        .rst_n         (rst_n),
        .system_ready  (system_ready),
        .wr_en         (wr_en),
        .rd_en         (rd_en),
        .full          (full),
        .empty         (empty),
        .wr_bin        (wr_bin),
        .rd_bin        (rd_bin),
        .illegal_write (illegal_write),
        .illegal_read  (illegal_read),
        .pointer_jump  (pointer_jump)
    );

    // Rule Checker
    rule_checker RC (
        .illegal_write(illegal_write),
        .illegal_read(illegal_read),
        .pointer_jump(pointer_jump),
        .rule_alert(rule_alert)
    );

    // Decision Tree
    decision_tree DT (
        .illegal_write(illegal_write),
        .illegal_read(illegal_read),
        .pointer_jump(pointer_jump),
        .ml_alert(ml_alert)
    );

    // Security Monitor
    security_monitor SM (
        .clk(wr_clk),
        .rst_n(rst_n),
        .rule_alert(rule_alert),
        .ml_alert(ml_alert),
        .trojan_alert(trojan_alert)
    );

endmodule