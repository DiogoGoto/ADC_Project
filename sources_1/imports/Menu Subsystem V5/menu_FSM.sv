
module menu_FSM    #(
        parameter int INPUT_TYPES = 3,                   // Bit width for duty_cycle
        parameter int SCALING_MODES = 3    // System clock frequency in Hz
    )
    (
    input logic        clk,
    input logic        reset,
    input logic        in_mode,
    input logic        scale_val_in,
    input logic        hex_BCD_in,
    input logic        ADC_sel_in,
    output logic [$clog2(INPUT_TYPES)-1 :0] out_sel,
    output logic [$clog2(SCALING_MODES)-1:0] scale_sel,
    output logic       hex_BCD_sel,
    output logic [1:0] ADC_sel,
    output logic       successive_approx
    );
    
    logic HEX_out;
    logic scale_out;
    logic mode_out;
    logic ADC_sel_out;
    
    
    //Impliment Button transition detectors for Menu
    Button_Transition_Detector b1 (
        .reset(reset),
        .clk(clk),
        .sig_in(in_mode),
        .sig_out(mode_out)
    );
    
        Button_Transition_Detector b2 (
        .reset(reset),
        .clk(clk),
        .sig_in(scale_val_in),
        .sig_out(scale_out)
    );
    
        Button_Transition_Detector b3 (
        .reset(reset),
        .clk(clk),
        .sig_in(hex_BCD_in),
        .sig_out(HEX_out)
    );
    
    Button_Transition_Detector b4 (
        .reset(reset),
        .clk(clk),
        .sig_in(ADC_sel_in),
        .sig_out(ADC_sel_out)
    );
    
    always_ff @ (posedge clk) begin //Counter 1: Input select (All zeros, Switches, ADC's)    
        if (reset)
            out_sel <= 'b0;
        else if (mode_out == 1) begin
            if(out_sel < INPUT_TYPES - 1)
                out_sel <= out_sel + 1;
            else
                out_sel <= 0;
        end
    end

    always_ff @ (posedge clk) begin //Counter 2: BCD or HEX      
            if (reset)
                hex_BCD_sel <= 0;
            else if (HEX_out == 1) begin //Input mode counter
                hex_BCD_sel = ~hex_BCD_sel;
        end
     end
     
   always_ff @ (posedge  clk) begin //Counter 3: scaling Modality
        if(reset)
            scale_sel <= 0;
            
        else if (scale_out == 1)
        
            if(scale_sel < SCALING_MODES - 1) scale_sel <= scale_sel + 1;
            else scale_sel <= 0;
            
   end
   
   //Modification: This changes how to switch the ADC modality, so we need a good way to select ADC's and the Successive approximation
   typedef enum logic [2:0] {S0,S1,S2,S3,S4} ADCstate;
   ADCstate state, next_state;
   
   always_ff @ (posedge clk)
   if(reset)
        state <= S0;
   else
        state <= next_state;
   
   //State Register for ADC select
   always_comb
        case(state)
            S0: next_state = ADC_sel_out ? S1 : S0;
            S1: next_state = ADC_sel_out ? S2 : S1;
            S2: next_state = ADC_sel_out ? S3 : S2;
            S3: next_state = ADC_sel_out ? S4 : S3;
            S4: next_state = ADC_sel_out ? S0 : S4;
            default: next_state = S0;
        endcase
   //Output logic for successive approx
   always_comb
        if (state == S2) successive_approx = 1;
        else if (state == S4) successive_approx = 1;
        else successive_approx = 0;
        
   //Output logic for ADC sel
      always_comb
        case(state)
            S0: ADC_sel = 0;
            S1: ADC_sel = 1;
            S2: ADC_sel = 1;
            S3: ADC_sel = 2;
            S4: ADC_sel = 2;
            default: ADC_sel = 0;
        endcase
   
   
endmodule
