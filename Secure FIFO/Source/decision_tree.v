`timescale 1ns/1ps
module decision_tree (
    input illegal_write,
    input illegal_read,
    input pointer_jump,
    output reg ml_alert
);

always @(*) begin
    if (pointer_jump)
        ml_alert = 1'b1;
    else if (illegal_write && illegal_read)
        ml_alert = 1'b1;
    else
        ml_alert = 1'b0;
end

endmodule