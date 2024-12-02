`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 02:17:34 PM
// Design Name: 
// Module Name: pwm_adc
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


module pwm_adc#(
    parameter int WIDTH =           8,           // Bit width for duty_cycle
    parameter int CLOCK_FREQ =      100_000_000, // Clock frequency (in Hz)
    parameter int SAMPLING_FREQ =   2000         // Sampling frequency(in Hz) 
)
(
    input logic                 clk,
    input logic                 reset,
    input logic                 pwm_en,
    input logic                 sa_en,
    input logic                 comparator,
    output logic                data_ready,
    output logic [15:0]         adc_out,
    output logic                pwm_out
    );

    //Internal Signals
    //============================================================================
    logic [WIDTH-1:0] ramp_duty_cycle, sa_duty_cycle;
    logic [WIDTH-1:0] duty_cycle;           
    logic [15:0]      ramp_raw, sa_raw;
    logic             ramp_ready, sa_ready;
    logic             comp_synced;
    logic             ramp_en, int_sa_en;

    //============================================================================

     //Control Logic
    //============================================================================
    always_comb begin
        // Enables
        if(sa_en && pwm_en) begin
            int_sa_en <= 1;
            ramp_en <=   0;
        end
        else begin
            ramp_en <= pwm_en;
            int_sa_en <= 0;
        end
        


        //Output
        if(sa_en) begin
            adc_out    <= sa_raw;
            data_ready <= sa_ready;
            duty_cycle <=sa_duty_cycle;
        end
        else begin 
            adc_out    <= ramp_raw;
            data_ready <= ramp_ready;
            duty_cycle <= ramp_duty_cycle;
        end
    end
    //============================================================================

    //Comparator Synchronizer
    //============================================================================
    synchronizer SYNC(
        .clk  (clk),
        .reset(reset),
        .in   (comparator),
        .out  (comp_synced)
    );

    // Algorithms 
    //============================================================================
    // Ramp
    sawtooth_generator #(
        .WIDTH      (WIDTH),             // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ (CLOCK_FREQ),        // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ  (SAMPLING_FREQ)      // Desired sample frequency in Hz (e.g. 1.0)
    ) RAMP_GENERATOR (
        .clk(clk),
        .reset(reset),
        .enable(ramp_en),
        .comparator(comp_synced),
        .data_ready(ramp_ready),
        .duty_cycle(ramp_duty_cycle),
        .adc_out(ramp_raw)
    );

    // Successive Approximation
    sucessive_approximation #(
        .WIDTH          (WIDTH),        // Bit width for duty_cycle
        .CLOCK_FREQ     (CLOCK_FREQ),   // Clock frequency (in Hz)
        .SAMPLING_FREQ  (SAMPLING_FREQ) // Sampling frequency(in Hz) 
    ) SA_PWM_ADC (
        .clk        (clk),
        .reset      (reset),
        .en         (sa_en),    
        .comparator (comparator),
        .data_ready (sa_ready),
        .dac_out    (sa_duty_cycle),
        .data_out   (sa_raw)
    );
    //============================================================================

    //PWM generator
    //============================================================================     
    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk(clk),
        .reset(reset),
        .enable(pwm_en),    // Use the enable input
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)   // Output PWM signal
    );

endmodule
