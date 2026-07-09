module security_monitor (
    input clk,
    input rst_n,
    input rule_alert,
    input ml_alert,
    output reg trojan_alert
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trojan_alert <= 1'b0;
        else if (rule_alert || ml_alert)
            trojan_alert <= 1'b1;  // Latched detection
    end

endmodule