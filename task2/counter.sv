module counter #(
    parameter WIDTH = 8
)(
    input logic clk,
    input logic rst,
    input logic en,
    // delete incr, fix the frequency
    output logic [WIDTH-1:0] count
);

always_ff @ (posedge clk)
    if (rst) count <= {WIDTH{1'b0}};
    else if (en) count <= count + {2'd3}; // sampled every 3 bits
    else count <= count + {WIDTH{1'b0}};
endmodule
