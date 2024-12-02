
module menu_FSM    #(
        parameter int INPUT_TYPES = 5,                   // Bit width for duty_cycle
        parameter int SCALING_MODES = 3    // System clock frequency in Hz
    )
    (
    input logic        clk,
    input logic        reset,
    input logic        in_mode,
    input logic        scale_val_in,
    input logic        hex_BCD_in,
    output logic [$clog2(INPUT_TYPES)-1 :0] out_sel,
    output logic [$clog2(SCALING_MODES)-1:0] scale_sel,
    output logic       hex_BCD_sel,
    output logic       successive_approx
    );
    
    logic HEX_out;
    logic scale_out;
    logic mode_out;
    
    
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
    
    always_ff @ (posedge clk) begin //Counter 1: Input select      
        if (reset)
            out_sel <= 0;
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
     
    /*always_ff @ (posedge clk) begin //Counter 1: Input select      
        if (reset)
            scale_sel <= 0;
        else if (scale_out == 1) begin
            if(scale_sel < 2)
                scale_sel <= scale_sel + 1;
            else begin
                scale_sel <= 0;
                successive_approx <= ~successive_approx;
            end
        end
    end    */ 
   
   always_ff @ (posedge  clk) begin
        if(reset) begin
            scale_sel <= 0;
            successive_approx <= 0;
        
        end else if (scale_out == 1) begin
            successive_approx <= ~successive_approx;
            if (successive_approx == 0)
                if(scale_sel < 2) scale_sel <= scale_sel + 1;
                else scale_sel <= 0;
        end
   
   end
   
endmodule
