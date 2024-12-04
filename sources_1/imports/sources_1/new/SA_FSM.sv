`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 08:07:05 PM
// Design Name: 
// Module Name: SA_FSM
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


module SA_FSM(
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic [2:0] current_state
    );

    //State Declaration
    typedef enum logic [2:0] {
        S0 = 3'b001,
        S1 = 3'b010,
        S2 = 3'b100
    } statetype;
    statetype state, next_state;

    //State Register
    always_ff @ (posedge clk) begin
        if(reset) begin 
            state <= S0;
        end
        else if(enable) begin
            state <= next_state;
        end
        else begin 
            state <= state;
        end
    end

    //Next State Logic
    always_comb begin 
        case (state)
            S0: next_state = S1; // Changing the R2R
            S1: next_state = S2; // Validating the change
            S2: next_state = S0; // Moving to next index
            default: next_state = S0;
        endcase
    end

    //Output logic
    assign current_state = state;
endmodule
