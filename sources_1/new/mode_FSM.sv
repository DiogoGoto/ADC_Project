`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 07:58:00 PM
// Design Name: 
// Module Name: mode_FSM
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


module mode_FSM(
    input logic clk,
    input logic reset,
    input logic mode_bt,
    output logic [1:0] mode_sel
    );

   //State Declaration
    typedef enum logic [2:0] {
        S0 = 3'b001, // All Zeros
        S1 = 3'b010, // Switches Inputs
        S2 = 3'b100  // ADCs results
    } statetype;
    statetype state, next_state;

    //State Register
    always_ff @ (posedge clk) begin
        if(reset) begin 
            state <= S0;
        end
        else begin 
            state <= next_state;
        end
    end

    //Next State Logic
    always_comb begin : NEXT_STATE_LOGIC
        next_state <= state;
        if (mode_bt) begin
        case (state)
            S0: next_state <= S1; 
            S1: next_state <= S2; 
            S2: next_state <= S0; 
            default: next_state <= S0;
        endcase
        end 
    end

    //Output logic
    always_comb begin : OUTPUT_LOGIC
        case (state)
            S0: mode_sel <= 2'b00;
            S1: mode_sel <= 2'b01;
            S2: mode_sel <= 2'b10;
            default: mode_sel <= 2'b00;
        endcase
    end
endmodule
