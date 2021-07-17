; Referenced from https://wiki.nesdev.com/w/index.php/Fixed_cycle_delay#50_cycles
; These are useful for cycle-counted code, to ensure that assembled branches
; do not include penalty cycles for page crossings

.macro branch_check opc, dest
    opc dest
    .assert >* = >(dest), warning, "branch_check: failed, crosses page"
.endmacro
.macro bccnw dest
        branch_check bcc, dest
.endmacro
.macro bcsnw dest
        branch_check bcs, dest
.endmacro
.macro beqnw dest
        branch_check beq, dest
.endmacro
.macro bnenw dest
        branch_check bne, dest
.endmacro
.macro bminw dest
        branch_check bmi, dest
.endmacro
.macro bplnw dest
        branch_check bpl, dest
.endmacro
.macro bvcnw dest
        branch_check bvc, dest
.endmacro
.macro bvsnw dest
        branch_check bvs, dest
.endmacro