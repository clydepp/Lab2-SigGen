#include "Vsinegen.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "vbuddy.cpp"

int main(int argc, char **argv, char **env) {
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);
    Vsinegen* top = new Vsinegen;

    // trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("sinegen.vcd");

    // sinegen is the top level entity
    top->clk = 1;
    top->rst = 0;
    top->en = 0;
    top->incr = 3;
    
    for (i=0; i<1000000; i++){

        for (clk=0; clk < 2; ++clk){
            tfp->dump (2*i+clk);
            top->clk = !top->clk;
            top->eval ();
        }
        top->rst = (i<2);
        top->en = (i>4);
        if ((Verilated::gotFinish()) || (vbdGetkey() =='q')) 
            exit(0);
    }
    tfp->close();
    exit(0);           // ... exit if finish OR 'q' pressed
}