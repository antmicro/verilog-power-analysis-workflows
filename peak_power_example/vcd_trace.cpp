// -*- mode: C++; c-file-style: "cc-mode" -*-
//
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2025 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <memory>

#include "Vgcd.h"

int errors = 0;

unsigned long long main_time = 0;
double sc_time_stamp() { return static_cast<double>(main_time); }

const char* trace_name() {
    static char name[1000];
    VL_SNPRINTF(name, 1000, "simx.vcd");
    return name;
}

int main(int argc, char** argv) {
    Verilated::debug(0);
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);

    std::unique_ptr<Vgcd> top{new Vgcd{"gcd_tb"}};

    std::unique_ptr<VerilatedVcdC> tfp{new VerilatedVcdC};

    static constexpr int SIMULATION_DURATION{150000};
    top->trace(tfp.get(), SIMULATION_DURATION);

    tfp->open(trace_name());

    while (main_time <= SIMULATION_DURATION) {
        top->clk = !top->clk;

        if (main_time == 20000) {
            top->reset = 1;
        }
        if (main_time == 25000) {
            top->reset = 0;
        }
        if (main_time == 40000) {
            top->req_msg = rand() & 0xffffffff;
            top->req_val = 0x1;
        }
        if (main_time == 45000) {
            top->req_val = 0x0;
        }
        if (main_time == 70000) {
            top->resp_rdy = 0x1;
        }
        if (main_time == 75000) {
            top->resp_rdy = 0x0;
        }

        top->eval();
        tfp->dump(static_cast<unsigned int>(main_time));
        main_time += 2500;
    }
    
    tfp->close();
    top->final();
    tfp.reset();
    top.reset();
    printf("*-* All Finished *-*\n");
    
    return errors;
}
