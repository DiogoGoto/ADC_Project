`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2024 09:49:12 AM
// Design Name: 
// Module Name: menu_FSM_TB
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


module menu_FSM_TB();
    
    // Parameters
    parameter CLK_PERIOD = 10, // 10ns for 100MHz clock
              clk_freq = 1/CLK_PERIOD,
              stable_time = 50,
              DEBOUNCE_4_ms = 4_000_000,
              OUNT_CYCLES  = 1.5*clk_freq*stable_time/1000;

    // Signals
    logic        clk;
    logic        reset;
    logic        in_mode;
    logic        scale_val_in;
    logic        hex_BCD_in;
    logic [3:0]  out_sel;
    logic [1:0]  scale_sel;
    logic        hex_BCD_sel;
    
    // Instantiate the Unit Under Test (UUT)
    menu_FSM uut 
    (
        .reset(reset),
        .clk(clk),
        .in_mode(in_mode),                       
        .scale_val_in(scale_val_in),                  
        .hex_BCD_in(hex_BCD_in),                    
        .out_sel(out_sel),  
        .scale_sel(scale_sel),
        .hex_BCD_sel(hex_BCD_sel)                    
    );
    
    always begin
        clk = 1;
        #(CLK_PERIOD/2);
        clk = 0;
        #(CLK_PERIOD/2);
    end
    
    
    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        
        #(CLK_PERIOD/2);
        reset = 0;
        #(CLK_PERIOD*(3/2));
        
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 1; scale_val_in = 1; hex_BCD_in = 1; #(3*CLK_PERIOD);
        
         in_mode = 0; scale_val_in = 0; hex_BCD_in = 0; #(3*CLK_PERIOD);
         
         in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 1; hex_BCD_in = 0; #(1*CLK_PERIOD);
        in_mode = 0; scale_val_in = 0; hex_BCD_in = 1; #(1*CLK_PERIOD);
        $stop;
    end
endmodule
