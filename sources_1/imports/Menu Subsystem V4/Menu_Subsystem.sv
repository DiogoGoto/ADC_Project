
module Menu_Subsystem(
//For Menu Selection
    input logic        clk,
    input logic        reset,
    input logic        in_mode,
    input logic        scale_val_in,
    input logic        hex_BCD_in,
    
//Interactions with outer modules: For the Bin_to_BCD module
    input logic [15:0] switches_in,
    output logic [15:0] bin_out,
    
//Inputs for XADC
    input logic [15:0] XADC_raw,XADC_ave,XADC_scaled,
//Inputs for PWM Ramp ADC
                       PWM_raw, PWM_ave, PWM_scaled,
//Inputs for R2R DAC
                       R2R_raw, R2R_ave, R2R_scaled,
                       
//Interaction with seven segment display
    input logic [15:0] bin_to_BCD_out,
    output logic [15:0] seven_segment_in,
//Interaction with ADC/DAC processing
    output logic successive_approx,
    output logic XADC_EN, R2R_EN, PWM_EN
);
    //Initialize intermediate signals
    logic [2:0] out_sel;
    logic [1:0] scale_sel;
    logic hex_BCD_sel;
    
    //Intermediate signals AFTER averaging MUX:
    logic [15:0] PWM_DAC_in, R2R_DAC_in, XADC_in;
    Mux_3 ave_sel_XADC (
        .in_1(XADC_raw),
        .in_2(XADC_ave),
        .in_3(XADC_scaled),
        .out(XADC_in),
        .select(scale_sel)
    );
    
    Mux_3 ave_sel_PWM (
        .in_1(PWM_raw),
        .in_2(PWM_ave),
        .in_3(PWM_scaled),
        .out(PWM_DAC_in),
        .select(scale_sel)
    );
    
     Mux_3 ave_sel_R2R (
        .in_1(R2R_raw),
        .in_2(R2R_ave),
        .in_3(R2R_scaled),
        .out(R2R_DAC_in),
        .select(scale_sel)
    );
    //Instantiate MUX3's for all ADC signals
    
    //Syncronizers and Debouncers for Buttons
    logic        in_mode_DB;
    logic        scale_val_in_DB;
    logic        hex_BCD_in_DB;
    
    debounce DB1(
        .clk(clk),
        .reset(reset),
        .button(in_mode),
        .result(in_mode_DB)
    );
    
        debounce DB2(
        .clk(clk),
        .reset(reset),
        .button(scale_val_in),
        .result(scale_val_in_DB)
    );
    
        debounce DB3(
        .clk(clk),
        .reset(reset),
        .button(hex_BCD_in),
        .result(hex_BCD_in_DB)
    );
    //Instantiate menu_FSM to take in
   menu_FSM FSM 
    (
        .reset(reset),
        .clk(clk),
        .in_mode(in_mode_DB),                       
        .scale_val_in(scale_val_in_DB),                  
        .hex_BCD_in(hex_BCD_in_DB),                    
        .out_sel(out_sel),  
        .scale_sel(scale_sel),
        .hex_BCD_sel(hex_BCD_sel),
        .successive_approx(successive_approx)                    
    );
    //Create Multiplexers for pipeline
    
    //MUX 1: FOR BETWEEN DAC/ADC MODULES AND BIN TO BCD
    always_comb 
        case(out_sel)
            0: bin_out = 16'b0000000000000000;
            1: bin_out = switches_in;
            2: bin_out = XADC_in;
            3: bin_out = PWM_DAC_in;
            4: bin_out = R2R_DAC_in; 
            default: bin_out = 16'b0000000000000000; 
        endcase
    //MUX 2: FOR BETWEEN BIN TO BCD AND SEVEN SEGMENT MODULE    
    always_comb 
        if(hex_BCD_sel == 1)
            seven_segment_in = bin_out;
        else
            seven_segment_in = bin_to_BCD_out;  
     
     assign scale_value_out = scale_sel;
     assign successive_approx = successive_approx;
     
     //NEW: Adding enables
     assign XADC_EN = (out_sel == 2) ? 1 : 0;
     assign PWM_EN = (out_sel == 3) ? 1 : 0;
     assign R2R_EN = (out_sel == 4) ? 1 : 0;
     
     
endmodule
