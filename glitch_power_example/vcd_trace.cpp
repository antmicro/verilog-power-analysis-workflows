// Copyright 2025 Antmicro <antmicro.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

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
