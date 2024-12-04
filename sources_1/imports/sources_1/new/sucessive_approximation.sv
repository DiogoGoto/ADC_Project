`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 10:47:02 AM
// Design Name: 
// Module Name: sucessive_approximation
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


module sucessive_approximation #(
    parameter int WIDTH = 8,                   // Bit width for duty_cycle
    parameter int CLOCK_FREQ = 100_000_000,               // Clock frequency (in Hz)
    parameter int SAMPLING_FREQ = 2_000                 // Period of the clock (in us)
)

    (
    input  logic clk,
    input  logic reset,
    input  logic comparator,
    input  logic en,
    output logic data_ready,
    output logic [7:0] dac_out,
    output logic [15:0] data_out
    );
    // Parameter
    //============================================================================
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ/ (SAMPLING_FREQ * 24));    

    // Ensure DOWNCOUNTER_PERIOD is positive
    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be above 0. Adjust CLOCK_FREQ or PERIOD.");
        end
    end
    //============================================================================


    // Internal signals
    //============================================================================
    logic zero;
    logic [2:0] state;
    logic [$clog2(WIDTH)-1:0] index;
    logic [WIDTH-1:0] temp_dac_out;
    //============================================================================

    // Counter
    //============================================================================
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)  // Set downcounter period based on calculations
    ) R2R_DOWNCOUNTER (
        .clk(clk),
        .reset(reset),
        .enable(en),  // Use the enable input
        .zero(zero)       // Pulses high every DOWNCOUNTER_PERIOD clock cycles
    );
    //============================================================================

    // Algorithm Implementation
    //============================================================================
    //Control FSM
    SA_FSM SA_FSM(
        .clk(clk),
        .reset(reset),
        .enable(zero),
        .current_state(state)
    );

    // Algorithm execution 
    always_ff @ (posedge clk) begin
        if(reset) begin
            temp_dac_out <= 0;
            dac_out <= 0;
            index <= WIDTH - 1;
        end
        if (zero) begin
            case (state)
                3'b001: dac_out[index] <= 1'b1;
                3'b010: begin 
                    if(comparator) temp_dac_out <= dac_out;
                    else            dac_out <= temp_dac_out;
                end 
                3'b100: begin
                    if(index == 0)begin
                        index <= WIDTH - 1;
                        temp_dac_out <= 0;
                        dac_out <=0;
                    end        
                    else index <= index - 1;
                end 
                default: dac_out <= dac_out;
            endcase
        end
    end
    //============================================================================

    // Output Logic
    //============================================================================
    always_ff @ (posedge clk) begin 
        if (reset) begin
            data_out <= 0;
            data_ready <= 0;
        end
        if((index == 0) && zero && (state == 3'b100))  begin
            data_out <= {4'b0, dac_out,4'b0}; //Padding the data
            data_ready <= 1'b1;
        end
        else begin
            data_out <= data_out;
            data_ready <= 0;
        end
    end
    //============================================================================


endmodule
