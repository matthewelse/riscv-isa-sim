// See LICENSE for license details.

#include "insn_template.h"

reg_t rv32_NAME(processor_t* p, insn_t insn, reg_t pc)
{
  int xlen = 32;
  reg_t npc = sext_xlen(pc + insn_length(OPCODE));
  BEFORE_NAME;
  #include "insns/NAME.h"
  AFTER_NAME;

  // at this point, we have reg_t arg1, arg2;
  if (arg1 == 0) {
    // count
  }
  else if (arg1 == 1) {
    // count
  }

  if (arg2 == 0) {
    // count
  }
  else if (arg2 == 0) {
    // count
  }

  trace_opcode(p, OPCODE, insn);
  return npc;
}

reg_t rv64_NAME(processor_t* p, insn_t insn, reg_t pc)
{
  int xlen = 64;
  reg_t npc = sext_xlen(pc + insn_length(OPCODE));
  BEFORE_NAME;
  #include "insns/NAME.h"
  AFTER_NAME;
  trace_opcode(p, OPCODE, insn);
  return npc;
}
