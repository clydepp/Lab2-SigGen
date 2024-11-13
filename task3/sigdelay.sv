module sigdelay #(
    parameter A_WIDTH = 9,
              D_WIDTH = 8
)(
    // interface signals
    input   logic  clk,
    input   logic  rst,
    input   logic  wr,
    input   logic  rd,
    input   logic  [D_WIDTH-1:0]  offset, // offset set by the rotary encoder
    input   logic  [D_WIDTH-1:0]  mic_signal,
    output  logic  [D_WIDTH-1:0]  delayed_signal 
);

logic [A_WIDTH-1:0] addr;

counter #(A_WIDTH) addrCounter (
    .clk (clk),
    .rst (rst),
    .count (addr) // this outputs addr
);

ram2ports #(A_WIDTH, D_WIDTH) audioRam (
    .clk        (clk),
    .wr_en      (wr),
    .rd_en      (rd),
    .wr_addr    (addr), // uses the counter output, writes mic_signal to this address
    .rd_addr    (addr - offset), // reads at addr - offset
    .din        (mic_signal), 
    .dout       (delayed_signal) // only output
);
endmodule
