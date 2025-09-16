.global _start
_start:

	.equ LEDs,  0xFF200000
	.equ TIMER, 0xFF202000
	.equ KEYS, 0xFF200050


	#Set up timer
	la t0, TIMER
	sw zero, 0(t0)   # clear the TO (Time Out) bit in case it is on
	li t1, 25000000    # load the delay value
	sw t1, 8(t0)   # write to the timer period register (low)
	srli t2, t1, 16  # shift right by 16 bits
	sw t2, 12(t0)   # write to the timer period register (high)
	
	li t1, 0b0111    # enable interrupts/continuous/start   
	sw t1, 4(t0)   # write those to the timer control register to 
					# start and go into continuous mode


	#Set up the stack pointer
	la sp, 0x20000
	
	
	/*Set up interrupt */
	
	csrw mstatus, zero
	
	li t0, 0x50000 			# 0x50000  bit 16 & 18 of 32 bit being 1 
	csrs mie, t0 			# this sets bit 16/18 of the MIE to 1, enabling interrupts specifically 

	la t1, KEYS 							
	li t0, 0b1111
	sw t0, 8(t1) #Enable KEY interrupts
	sw t0, 12(t1) #Clears edgecapture register of KEY_BUTTONS

	la t0, interrupt_handler
	csrw mtvec, t0	
	
	li t0, 0b1000			# turn on bit three of register t0
	csrs mstatus, t0      # use it to turn on bit 3 of MSTATUS - the MIE bit to enable processor interrupts


	
	#jal    CONFIG_TIMER        # configure the Timer
    #jal    CONFIG_KEYS         # configure the KEYs port
	
	li a0, 25000000 #Starting timer speed
	
	la s0, LEDs
	la s1, COUNT
	
	LOOP:
		lw     s2, 0(s1)          # Get current count
		li t3, 256
		beq s2, t3, reset
		sw     s2, 0(s0)          # Store count in LEDs
	j LOOP
	
	reset:
	sw zero, (s1)
	j LOOP




interrupt_handler:
	addi sp, sp, -16
	
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw s2, 8(sp)
	sw ra, 12(sp)
	
	li s0, 0x7FFFFFFF #Get rid off bit 31
	csrr s1, mcause
	
	and s1, s1, s0 #Make bit 31 = 0

	li s0, 18
	beq s1, s0, KEY_INTERRUPT #If cause is key press, call key handler
	li s0, 16
	beq s1, s0, TIMER_INTERRUPT #If cause is timer, call timer handler
	j end_interrupt #No interrupts

	
	KEY_INTERRUPT:
	la s1, KEYS
	lw s2, 12(s1)
	li s0, 0b0001
	beq s0, s2, toggle
	li s0, 0b0010
	beq s0, s2, speedup
	li s0, 0b0100
	beq s0, s2, slowdown
	j end_interrupt

	TIMER_INTERRUPT:
	call CONFIG_TIMER
	j end_interrupt
	
	toggle:
	call CONFIG_KEY0
	j end_interrupt
	
	speedup:
	li s0, 100000000
	beq a0, s0, end_interrupt #Min speed
	call CONFIG_KEY1
	j end_interrupt
	
	slowdown:
	li s0, 3125000
	beq a0, s0, end_interrupt #Max speed
	call CONFIG_KEY2
	j end_interrupt
	
	end_interrupt:

	la a1, KEYS
	li s0, 0b1111
	sw s0, 12(a1) #Clear edgecapture register
	
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw s2, 8(sp)
	lw ra, 12(sp)
	
	addi sp, sp, 16
	
mret


CONFIG_TIMER: 
	#Code 
	addi sp, sp, -20
	sw s0, 0(sp)
	sw a1, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw ra, 16(sp)
	
	la s0, COUNT
	lw a1, (s0)
	la s1, RUN
	lw s2, (s1)
	add a1, a1, s2 #Add to COUNT
	sw a1, (s0)
	
	la a1, TIMER
	sw zero, 0(a1) #Clear the TO bit
	
	lw s0, 0(sp)
	lw a1, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw ra, 16(sp)
	addi sp, sp, 20

ret

CONFIG_KEY0: 
	#Code 
	addi sp, sp, -16
	sw s0, 0(sp)
	sw a1, 4(sp)
	sw s1, 8(sp)
	sw ra, 12(sp)
	
	la s0, RUN
	lw a1, (s0)
	li s1, 1
	xor a1, a1, s1 #Stop RUN
	sw a1, (s0)
	
	la a1, KEYS
	li s0, 0b1111
	sw s0, 12(a1) #Clear edgecapture register
	
	lw s0, 0(sp)
	lw a1, 4(sp)
	lw s1, 8(sp)
	sw ra, 12(sp)
	
	addi sp, sp, 16

ret

CONFIG_KEY1: 
	#Code 
	addi sp, sp, -16
	sw s0, 0(sp)
	sw a1, 4(sp)
	sw s1, 8(sp)
	sw ra, 12(sp)
	
	
	li s0, 0b1000 #Stop timer
	la s1, TIMER
	sw s0, 4(s1)
	
	slli a0, a0, 1 #Divide the timer duration by 2
	sw a0, 8(s1)   # write to the timer period register (low)
	srli s0, a0, 16  # shift right by 16 bits
	sw s0, 12(s1)   # write to the timer period register (high)
	
	li s0, 0b0111 #Restart timer
	la s1, TIMER
	sw s0, 4(s1)
	
	li s0, 0b1111
	la a1, KEYS
	sw s0, 12(a1) #Clear edgecapture register
	
	lw s0, 0(sp)
	lw a1, 4(sp)
	lw s1, 8(sp)
	sw ra, 12(sp)
	
	addi sp, sp, 16

ret

CONFIG_KEY2: 
	#Code 
	addi sp, sp, -16
	sw s0, 0(sp)
	sw a1, 4(sp)
	sw s1, 8(sp)
	sw ra, 12(sp)
	
	
	li s0, 0b1000 #Stop timer
	la s1, TIMER
	sw s0, 4(s1)
	
	srli a0, a0, 1 #Divide the timer duration by 2
	sw a0, 8(s1)   # write to the timer period register (low)
	srli s0, a0, 16  # shift right by 16 bits
	sw s0, 12(s1)   # write to the timer period register (high)
	
	li s0, 0b0111 #Restart timer
	la s1, TIMER
	sw s0, 4(s1)
	
	li s0, 0b1111
	la a1, KEYS
	sw s0, 12(a1) #Clear edgecapture register
	
	lw s0, 0(sp)
	lw a1, 4(sp)
	lw s1, 8(sp)
	sw ra, 12(sp)
	
	addi sp, sp, 16

ret



.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end
