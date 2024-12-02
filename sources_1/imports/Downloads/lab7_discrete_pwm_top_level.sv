`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 09:37:55 AM
// Design Name: 
// Module Name: lab7_discrete_pwm_top_level
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab7_discrete_pwm_top_level(
    input logic comparator_state,
    input logic clk,
    input logic rst,
    input logic pwm_enable,
    output logic [7:0] duty_cycle_bits,
    output logic pwm_out,
    output logic edas_to_register_falling,
    output logic edas_to_register_rising,
    output logic [7:0] r2r_output
    );
    
    logic connector1 = edas_to_register_falling;
    logic connector2 = edas_to_register_rising;
    
    
    falling_edge falling_edge_detector(
        .clk(clk),
        .rst(rst),
        .comparator_state(comparator_state),
        .sync_comparator_state(edas_to_register_falling)
    );
    
    rising_edge rising_edge_detector(
        .clk(clk),
        .rst(rst),
        .comparator_state(comparator_state),
        .sync_comparator_state2(edas_to_register_rising)
    );
    
    sawtooth_generator pwm_producter(
        .clk(clk),
        .reset(rst),
        .enable(pwm_enable),
        .falling_edge(edas_to_register_falling),
        .pwm_out(pwm_out),
        .R2R_out(r2r_output),
        .duty_cycle_out(duty_cycle_bits)
    );
    
endmodule
