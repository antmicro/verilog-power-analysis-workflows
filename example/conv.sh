#!/bin/bash

for file in *.sv; do
    module=$(basename -s .sv "$file")
    sv2v --define=RVFI --define=SYNTHESIS --define=YOSYS ./*_pkg.sv prim_assert.sv "$file" > "verilog/${module}".v
done

rm -f ./*_pkg.v prim_assert.v prim_util_memload.v