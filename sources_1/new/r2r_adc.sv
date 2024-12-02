`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 10:18:26 AM
// Design Name: 
// Module Name: r2r_adc
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


module r2r_adc #(
    parameter int WIDTH =           8,           // Bit width for duty_cycle
    parameter int CLOCK_FREQ =      100_000_000, // Clock frequency (in Hz)
    parameter int SAMPLING_FREQ =   2000         // Sampling frequency(in Hz) 
)
(
    input logic                 clk,
    input logic                 reset,
    input logic                 r2r_en,
    input logic                 sa_en,
    input logic                 comparator,
    output logic                data_ready,
    output logic [15:0]         adc_out,
    output logic [WIDTH-1:0]    r2r_out
    );
    //Internal Signals
    //============================================================================
    logic [WIDTH-1:0] ramp_waveform, sa_waveform;
    logic [15:0]      ramp_raw, sa_raw;
    logic             ramp_ready, sa_ready;
    logic             comp_synced;
    logic             ramp_en, int_sa_en;
    //============================================================================

    //Control Logic
    //============================================================================
    always_comb begin
        // Enables
        if(sa_en && r2r_en) begin
            int_sa_en <= 1;
            ramp_en <=   0;
        end
        else begin
            ramp_en <= r2r_en;
            int_sa_en <= 0;
        end
        


        //Output
        if(int_sa_en) begin
            adc_out    <= sa_raw;
            data_ready <= sa_ready;
            r2r_out    <= sa_waveform;
        end
        else begin 
            adc_out    <= ramp_raw;
            data_ready <= ramp_ready;
            r2r_out    <= ramp_waveform;
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
    //============================================================================

    // Algorithms 
    //============================================================================
    // Ramp
    ramp_generator #(
        .WIDTH      (WIDTH),             // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ (CLOCK_FREQ),        // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ  (SAMPLING_FREQ)      // Desired sample frequency in Hz (e.g. 1.0)
    ) RAMP_GENERATOR (
        .clk        (clk),               // Connect to system clock
        .reset      (reset),             // Connect to system reset
        .enable     (ramp_en),           // Connect to enable signal
        .comparator (comp_synced),       // Connect to comparator signal
        .data_ready (ramp_ready),        // Connect to data ready signal
        .R2R_out    (ramp_waveform),     // Connect to R2R ladder header, can leave empty if 
        .ADC_OUT    (ramp_raw)           // Connect to the data output
    );

    // Successive Approximation
    sucessive_approximation #(
        .WIDTH          (WIDTH),        // Bit width for duty_cycle
        .CLOCK_FREQ     (CLOCK_FREQ),   // Clock frequency (in Hz)
        .SAMPLING_FREQ  (SAMPLING_FREQ) // Sampling frequency(in Hz) 
    ) SA_R2R_ADC (
        .clk        (clk),
        .reset      (reset),
        .en         (int_sa_en),    
        .comparator (comparator),
        .data_ready (sa_ready),
        .dac_out    (sa_waveform),
        .data_out   (sa_raw)
    );
    //============================================================================
endmodule
