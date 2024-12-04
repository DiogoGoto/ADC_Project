module Mux_3(
    input logic [15:0] in_1,in_2,in_3,
    input logic [1:0] select,
    output logic [15:0] out
    );
    
    
    always_comb
        case(select)
            0: out = in_1;
            1: out = in_2;
            2: out = in_3;
            default: out = in_1;
        endcase
endmodule
