`timescale 1ns/1ps
module rule_checker (
    input illegal_write,
    input illegal_read,
    input pointer_jump,
    output rule_alert
);

assign rule_alert = illegal_write | illegal_read | pointer_jump;

endmodule