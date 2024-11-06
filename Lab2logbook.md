# Lab 2 - Signal Generation and Capture
## Task 1 - Simple sinewave generator
#### Specifying a 256 x 8 bit ROM
In the ***task1*** folder, I wrote **rom.sv** to specify a 256 x 8 bit ROM. Parameters for address and data width are specified at the top of the file - important that the module definition includes a `#`.
```
logic [DATA_WIDTH-1:0] rom_array [2**ADDRESS_WIDTH-1:0];

initial begin
        $display("Loading rom.");
        $readmemh("sinerom.mem", rom_array);
end;
```

The code above highlights two parts of this specification: first, the rom has data with bits addressable from 0 to **DATA_WIDTH** in each address. There are $2^{ADDRESS{\textunderscore}WIDTH}$ addresses in this rom module.

In the second part, the `initial begin` statement runs at the start of the simulation. The `$display` line is used to print messages onto the console/terminal - this prints the message enclosed. The `$readmemh` line reads the data from the file and stores in the local variable. 

#### Create the sinegen module
```
counter addrCounter (
    .clk (clk),
    .rst (rst),
    .en (en),
    .incr (incr),
    .count (address)
);

rom sineRom (
    .clk (clk),
    .addr (address),
    .dout (dout)
);
```
The code above shows that **sinegen.sv** uses instances of **rom.sv** and **counter.sv**, the `.count` is the internal signal name (the name of the variables in the original file).
The name within the brackets, i.e. `(address)` is the external signal name - which is usually interconnect wires or interface signals from this 'main' file.

### TEST YOURSELF CHALLENGE
Within my counter module, I have an 8 bit input *incr*, with which I set the value of in the testbench using `top->incr = vbdValue();`.

## Task 2 - Sine and Cosine Dual wave generation
#### Making a dual-port ROM

#### Making the phase difference 90deg
## Task 3 - Capture and display audio signal in RAM
