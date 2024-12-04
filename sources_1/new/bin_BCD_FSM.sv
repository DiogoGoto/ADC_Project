`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 07:58:00 PM
// Design Name: 
// Module Name: bin_BCD_FSM
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


module bin_BCD_FSM(
    input logic clk,
    input logic reset,
    input logic bin_bcd_bt,
    output logic hex_bcd_sel
    );

   //State Declaration
    typedef enum logic [1:0] {
        S0 = 2'b01, // Bin Out
        S1 = 2'b10  // BCD Out
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
        if(bin_bcd_bt) begin
        case (state)
            S0: next_state <= S1; 
            S1: next_state <= S0; 
            default: next_state <= S0;
        endcase
        end
        
    end

    //Output logic
    always_comb begin : OUTPUT_LOGIC
        case (state)
            S0: hex_bcd_sel <= 0; // Bin Out
            S1: hex_bcd_sel <= 1; // BCD Out
            default: hex_bcd_sel <= 0; // Bin Out
        endcase
    end
endmodule
