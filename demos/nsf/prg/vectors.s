        .include "../../common/nes.inc"

        .segment "CODE"

; currently, we don't need IRQ and NMI
; but it's accessible in NSF2 in non-returning init mode
; if we ever get to it for Z-Saw
.proc irq
        rti
.endproc

.proc nmi
        rti
.endproc