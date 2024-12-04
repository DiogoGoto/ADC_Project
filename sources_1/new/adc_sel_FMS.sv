`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2024 07:58:00 PM
// Design Name: 
// Module Name: adc_sel_FMS
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


module adc_sel_FMS(
    input logic clk,
    input logic reset,
    input logic adc_bt,
    output logic [1:0] adc_sel,
    output logic pwm_en,
    output logic r2r_en,
    output logic sar_en,
    output logic xadc_en
    );

   //State Declaration
    typedef enum logic [4:0] {
        S0 = 5'b00001, // PWM RAMP
        S1 = 5'b00010, // PWM SAR
        S2 = 5'b00100, // R2R RAMP
        S3 = 5'b01000, // R2R SAR
        S4 = 5'b10000  // XADC
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
        if(adc_bt) begin
            case (state)
                S0: next_state <= S1; 
                S1: next_state <= S2; 
                S2: next_state <= S3; 
                S3: next_state <= S4;
                S4: next_state <= S0;  
                default: next_state <= S0;
            endcase
        end
    end

    //Output logic
    always_comb begin : OUTPUT_LOGIC
        case (state)
            S0: begin // PWM RAMP
                adc_sel <= 2'b00;
                xadc_en <= 0;
                pwm_en  <= 1;
                r2r_en  <= 0;
                sar_en  <= 0;
            end
            S1: begin // PWM SAR
                adc_sel <= 2'b00;
                xadc_en <= 0;
                pwm_en  <= 1;
                r2r_en  <= 0;
                sar_en  <= 1;
            end
            S2: begin // R2R RAMP
                adc_sel <= 2'b01;
                xadc_en <= 0;
                pwm_en  <= 0;
                r2r_en  <= 1;
                sar_en  <= 0;
            end
            S3: begin // R2R SAR
                adc_sel <= 2'b01;
                xadc_en <= 0;
                pwm_en  <= 0;
                r2r_en  <= 1;
                sar_en  <= 1;
            end
            S4: begin // XADC
                adc_sel <= 2'b10;
                xadc_en <= 1;
                pwm_en  <= 0;
                r2r_en  <= 0;
                sar_en  <= 0;
            end
            default:begin // All off
                adc_sel <= 2'b00;
                xadc_en <= 0;
                pwm_en  <= 0;
                r2r_en  <= 0;
                sar_en  <= 0;
            end 
        endcase
    end
endmodule
