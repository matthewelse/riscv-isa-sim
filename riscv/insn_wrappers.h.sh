#!/bin/sh

if [ -z "$1" ]; then
  printf "Error: must give source base directory as first argument\n" 1>&2
  exit 1
fi

ENCODING_H="$1/riscv/encoding.h"

if ! [ -e "$ENCODING_H" ]; then
  printf "Error: can't find encoding .h\n" 1>&2
  exit 1
fi


INSN_LIST=$(grep ^DECLARE_INSN "$ENCODING_H" | sed 's/DECLARE_INSN(\(.*\),.*,.*)/\1/')

# First, define empty 'wrappers'

for INSN in $INSN_LIST; do
  printf "#define BEFORE_$INSN\n#define AFTER_$INSN\n"
done

# Now redefine wrappers for instructions which influence the tag pipeline

TAG_ALU_RI_INSNS="addi addiw andi ori slli slliw slti sltiu srai sraiw srli
                  srliw xori"
TAG_ALU_RI_ARGS=$(cat <<'EOF'
  reg_t arg1 = RS1; \
  reg_t arg2 = insn.i_imm(); \
EOF
)

TAG_ALU_RR_INSNS="add addw and div divu divuw divw mul mulh mulhsu mulhu
                  mulw or rem remu remuw remw sll sllw slt sltu sra sraw
                  srl srlw sub subw xor"
TAG_ALU_RR_ARGS=$(cat <<'EOF'
  reg_t arg1 = RS1; \
  reg_t arg2 = RS2; \
EOF
)

TAG_ALU_II_INSNS="auipc lui"
TAG_ALU_II_ARGS=$(cat <<'EOF'
  reg_t arg1 = insn.u_imm(); \
  reg_t arg2 = 0xDEADBEEF; // have a better way of indicating that this is not used \
EOF
)

EOL="\\\\\n"

BEFORE_TAG_ALU=$(cat <<'EOF'
EOF
)

AFTER_TAG_ALU=$(cat <<'EOF'
EOF
)

def_tag_alu() {
  for INSN in $1; do
    printf "#undef BEFORE_$INSN\n#undef AFTER_$INSN\n"
    printf "#define BEFORE_$INSN $EOL"
    printf "%s\n" "$2"
    printf "%s\n" "$BEFORE_TAG_ALU"
    printf "#define AFTER_$INSN $EOL"
    printf "%s\n" "$AFTER_TAG_ALU"
  done
}

def_tag_alu "$TAG_ALU_RI_INSNS" "$TAG_ALU_RI_ARGS"
def_tag_alu "$TAG_ALU_RR_INSNS" "$TAG_ALU_RR_ARGS"
def_tag_alu "$TAG_ALU_II_INSNS" "$TAG_ALU_II_ARGS"

TAG_STORE_INSNS="sb sd sh sw fsw fsd"
for INSN in $TAG_STORE_INSNS; do
  printf "#undef BEFORE_$INSN\n#undef AFTER_$INSN\n"
  printf "#define BEFORE_$INSN $EOL"
  cat <<'EOF'
EOF
  printf "#define AFTER_$INSN $EOL"
  cat <<'EOF'
EOF
done

TAG_LOAD_INSNS="lb lbu ld lh lhu lw lwu flw fld"
for INSN in $TAG_LOAD_INSNS; do
  printf "#undef BEFORE_$INSN\n#undef AFTER_$INSN\n"
  printf "#define BEFORE_$INSN $EOL"
  cat <<'EOF'
EOF
  printf "#define AFTER_$INSN $EOL"
  cat <<'EOF'
EOF
done
