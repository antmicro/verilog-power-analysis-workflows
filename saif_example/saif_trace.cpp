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
#include <verilated_saif_c.h>

#include <memory>

#include "Vibex.h"

int main(int argc, char** argv) {
    Verilated::debug(0);
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);

    std::unique_ptr<Vibex> top{new Vibex{"ibex_tb"}};

    std::unique_ptr<VerilatedSaifC> tfp{new VerilatedSaifC};

    static constexpr int SIMULATION_DURATION{150000};
    top->trace(tfp.get(), SIMULATION_DURATION);

    tfp->open("simx.saif");

    unsigned long long main_time = 0;
    while (main_time <= SIMULATION_DURATION) {
        top->clk_i = !top->clk_i;

        top->eval();
        tfp->dump(static_cast<unsigned int>(main_time));
        
        // from ibex's constraint.sdc clock period value
        main_time += 630;
    }
    
    tfp->close();
    top->final();

    printf("*-* All Finished *-*\n");
    
    return 0;
}