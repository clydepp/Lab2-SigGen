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
Within my counter module, I have an 8 bit input *incr*, with which I set the value of in the testbench using `top->incr = vbdValue();`. This changes the frequency of the sinusoid, such to a point that the signal frequency is so low that points from old wave cycles seem to overlap - causing a plot which looks like a set of scattered points. I altered this by adding a scale factor to the increment - so that the rotary encoder has a weaker (and more controllable) impact on the plot. I chose a scale factor of $\frac{1}{10}$, which meant that when v = 10 (on the Vbuddy), the wave would start oscillating - with a frequency of 1unit.
```
else if (en) count <= count + {incr/10};
```

## Task 2 - Sine and Cosine Dual wave generation
#### Making a dual-port ROM
My implementation of the dual-port ROM requires one address input. The reason I have made this choice is seen later.
```
input logic [ADDRESS_WIDTH-1:0] addr,
output logic [DATA_WIDTH-1:0] dout1,
output logic [DATA_WIDTH-1:0] dout2
```
It can be seen that there are two outputs, both of which are displayed and seen on the Vbuddy screen at the same time. It may seem that the plot is the same - but it is just defined over all 8-bit values 0 to 255 (see quantization in Signals and Systems).
```
vbdPlot(int (top->dout1), 0, 255);
vbdPlot(int (top->dout2), 0, 255);
```
#### Making the phase difference 90deg
My choice to only include one address was to implement this phase difference easier. A change I made was adding another output *dout2*, which would be the second sinusoid - and the shifted version of the original signal. Setting this with two inputs to *addr1* and *addr2* would require the person writing the testbench to have make a conscious choice to calculate this offset manually.
```
dout1 <= rom_array [addr];
dout2 <= rom_array [addr + 7'd64];
```
It can be seen that the second output is the first signal with a shift of 64 bits. This is shown with the code above and the image of the plot below:
<p align = "center"><img src="https://github.com/user-attachments/assets/32c4a032-6361-4b5a-b426-8d7cbfe464d0" width=20% height=20%></p>

Now, change the phase: use the rotary encoder as an input for the offset in the testbench - `top->incr = vbdValue();`. In order to use the rotary encoder, the frequency of the sinusoids must be fixed - increments of `2'd3` gives a stable signal. 

Multiplying the increment by 2 allows the two signals to be in antiphase. Without this, the phase difference is limited to a phase difference of 140deg. 
```
dout2 <= rom_array [addr + incr*{2'd2}];
```
By inspection, the original waveform does not change, but the copy changes in phase when the rotary encoder value is changed. This can be seen below:
<p align = "center"><img src="https://github.com/user-attachments/assets/b477aa78-27f1-4e98-b91c-26d4aa01d28e" width=20% height=20%></p>


## Task 3 - Capture and display audio signal in RAM
The testbench is already written, and uses functions to sample the audio signal.
```
// intialize variables for analogue output
vbdInitMicIn(RAM_SZ);
  
// ask Vbuddy to return the next audio sample
top->mic_signal = vbdMicValue();
```

The first function, ***vbdInitMicIn(RAM_SZ)*** uses the predefined value *RAM_SZ* (the number of addresses in RAM) to find a suitable size of sampling. In the case of the 512 x 8 RAM module, the mic will record 512 values and store them in a buffer.

The next function, ***vbdMicValue()***, records the amplitudes of the signal as captured by the mic. This sets the input for the RAM module, the values that are written and read from.

The setup of the *sigdelay.sv* file is as follows:
![image](https://github.com/user-attachments/assets/928681b5-3bdf-4c90-95f3-986fb0ff38fd)
* The output from counter is used as the address for the RAM
* The read address is the address of the write values minus an offset
* The offset is set by the rotary encoder using `vbdValue()`
* The output of the RAM is the shifted value
* The values in the addresses are the values in the buffer of the write input from `vbdMicValue()`
