// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"

int main(int argc, char **argv) {
  puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');

  return 0;
}
