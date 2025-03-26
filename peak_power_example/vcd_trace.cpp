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

    static constexpr int SIMULATION_DURATION{200};
    top->trace(tfp.get(), SIMULATION_DURATION);

    tfp->open(trace_name());

    // #clk_period reset = 1;
    // #clk_period reset = 0;

    // #clk_period a = 1053775287; b = 412654; req_val = 1;
    // #clk_period req_val = 0;
    // #clk_period
    // #clk_period
    // #clk_period
    // #clk_period
    // #clk_period
    // #clk_period resp_rdy = 1;
    // #clk_period resp_rdy = 0;
    // #clk_period

    top->clk = 0;
    top->req_val = 0;
    top->resp_rdy = 0;
    top->reset = 0;

    for (int cycle = 0; cycle < 30; ++cycle) {
        top->clk = 0;

        top->eval();
        tfp->dump(static_cast<unsigned int>(main_time));
        main_time += 2500;

        top->clk = 1;

        if (cycle == 5) {
            top->req_msg = rand() & 0xffffffff;
            top->req_val = 1;
        } else if (cycle == 6) {
            top->req_val = 0;
        }

        if (cycle == 15) {
            top->resp_rdy = 1;
        } else if (cycle == 16) {
            top->resp_rdy = 0;
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
