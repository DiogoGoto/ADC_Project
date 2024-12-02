module Button_Transition_Detector(
    input logic sig_in,
    input logic clk,
    input logic reset,
    output logic sig_out
    );
    
    typedef enum logic [1:0] {S0,S1,S2} statetype;
    statetype state, nextstate;
    
    always_ff @ (posedge clk)
        if(reset) state <= S0;
        else      state <= nextstate;
        
    always_comb
        case (state)
            S0:     nextstate = sig_in ? S0 : S1;
            S1:     nextstate = sig_in ? S2 : S1;
            S2:     nextstate = sig_in ? S0 : S1;
            default: nextstate = S0;
        endcase
        
    assign sig_out = (state == S2);
endmodule
