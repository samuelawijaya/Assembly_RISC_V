/* Program to turn LED 0 on and off in 
 response to key2 button being pressed and released 
Uses the Edge capture register (vs. The Data register).
This program uses the polling method, on the Edge Capture Register.
*/
		.equ LEDs, 0xFF200000
		.equ KEY_BASE, 0xFF200050
		.equ TIMER_BASE, 0xFF202000


.global _start

_start:  la t0, KEY_BASE	# set t0 to base KEY port
	 	  la  t1,LEDs			# set t1 to base of LEDR port
	 	  li  t2, 0				# Original state of LEDR = stop = 0
		  li s0, 0
		  li s1, 1
		  li s7, 0x0 # Hundredth second shifted
		  li s8, 0x0 # Second count
		  li s9, 0x0 # Hundredth second count
		  li s10, 0x0 # time total
		  
		  li a4, 100
		  li a5, 8
		  
		la s4, TIMER_BASE
		sw zero, 0(s4)   # clear the TO (Time Out) bit in case it is on
		li s5, 1000000    # load the delay value
		sw s5, 0x8(s4)   # write to the timer period register (low)
		srli s2, s5, 16  # shift right by 16 bits
		sw s2, 0xc(s4)   # write to the timer period register (high)
		
		li s5, 0b0110    # bits to enable continuous mode and start  
		sw s5, 0x4(s4)   # write those to the timer control register to 
					     # start and go into continuous mode

		  
		  

poll:	  lw t3, 0xC(t0)		# load edge capture edge reg
			bne t3, s0, edgeinvert
			beq t2, s1, loop
			beqz t3, poll
			
		  edgeinvert: 
		  xori  t2,t2, 1		# invert t2 for next time the button released
		 
		  li  t4, 0xF		# turn off edge capture bit
		  sw t4, 0xC(t0)		# by writing 1 into bit 2  
		 
		  j	poll			# go back to poll loop

loop: 
or s10, s7, s9 		# Adds second and hundredth second
sw s10, (t1)		# change LED

ploop:
lw t3, 0xC(t0)
bne t3, s0, edgeinvert

lw s5, 0(s4)
andi s5, s5, 0b1   # mask the TO bit
beqz s5, ploop     # if TO bit is 0, wait
sw zero, 0(s4)     # clear the TO bit
			
addi s9, s9,  1    # Increment 0.01
beq s9, a4, hundredthreset
j loop

hundredthreset:
addi s8, s8, 1 # 1 second elapsed
slli s7, s8, 7 #Shift 7 bits to the left
beq s8, a5, reset #reset timer
li s9, 0
j loop

reset:
li s8, 0
li s9, 0
j loop


