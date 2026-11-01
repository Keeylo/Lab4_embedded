;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 4 starter file
; March 25, 2016

;


        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR
    CPSID   I                  ; 2) Prevent interrupt during switch
	;YOU IMPLEMENT THIS (same as Lab 3)
	PUSH {R4-R11} ; save state, preparation to switch threads
	LDR	R0, =RunPt ; load in RunPt variable address
	LDR R1, [R0] ; load in address of TCB/SP (address RunPt points to)
	STR SP, [R1] ; save CPU stack pointer address, done by storing value associated with TCB/SP address
	PUSH {R0, LR} ; save link register to stack to remember where SysTick was called from
	BL Scheduler ; branch to Scheduler function to update RunPt reference with new thread
	POP {R0, LR} ; restore link register as this is where we will return to
	LDR R1, [R0] ; load in new TCB/SP address to R1 from RunPt
	LDR SP, [R1] ; load in value TCB/SP points to, hand it to the CPU stack pointer
	POP {R4-R11}
    CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS
    ;YOU IMPLEMENT THIS (same as Lab 3)
    CPSIE   I                  ; Enable interrupts at processor level
	LDR R0, =RunPt ; loading in RunPt variable address
	LDR R2, [R0] ; loading in RunPt value, which is TCB/SP variable address
	LDR SP, [R2] ; loading in value at the address the TCB/SP pointed to
	POP {R4-R11}
	POP {R0-R3}
	POP {R12}
	ADD SP, SP,#4
	POP {LR}
	ADD SP, SP,#4
    BX      LR                 ; start first thread

    ALIGN
    END
