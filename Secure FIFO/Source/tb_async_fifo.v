`timescale 1ns/1ps

module tb_async_fifo;

    reg wr_clk = 0;
    reg rd_clk = 0;
    reg rst_n  = 0;
    reg wr_en  = 0;
    reg rd_en  = 0;
    reg [7:0] data_in = 8'hA0;

    wire [7:0] data_out;
    wire full;
    wire empty;
    wire trojan_alert;

    // Instantiate DUT
    async_fifo_top DUT (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .trojan_alert(trojan_alert)
    );

    // Clock generation
    always #5 wr_clk = ~wr_clk;  // 10 ns period
    always #7 rd_clk = ~rd_clk;  // 14 ns period

    integer i;

    initial begin
        // Reset
        #20 rst_n = 1;

        // Write operations to trigger Trojan IV
        wr_en = 1;
        for (i = 0; i < 20; i = i + 1) begin
            #10;  // Deterministic delay instead of @(posedge)
            data_in = 8'hA0 + i;
        end
        wr_en = 0;

        // Allow some time before reads
        #40;

        // Read operations
        rd_en = 1;
        #140;
        rd_en = 0;

        // Observation window
        #100;

        $display("Simulation completed successfully.");
        $finish;
    end

    initial begin
        $monitor("T=%0t | data_in=%h | data_out=%h | full=%b | empty=%b | trojan_alert=%b",
                 $time, data_in, data_out, full, empty, trojan_alert);
    end

endmodule