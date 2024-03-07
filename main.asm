

.global _start
	
	_start:
	
		la t6, IEEE754_64_rep
	
		la a0 num_req
		li a7, 4
		ecall
		
		li a7, 5
		ecall
		mv t0, a0	#recording the num to t0
		
		li t3, 31
		mv t2, t0
		sra t2, t2, t3            # Shift the value to the right by 31 positions
    		andi t4, t2, 1  	# now sign of divisor is stored in t4
    		
    		bnez t4, invertDividend
    		cont1:
	
		la a0 denum_req
		li a7, 4
		ecall
		
		li a7, 5
		ecall
		mv t1 a0	#recording the denum to t1
		
		mv t2, t1
		sra t2, t2, t3            # Shift the value to the right by 31 positions
    		andi t5, t2, 1  	# now sign of divisor is stored in t4
    		
    		bnez t5, invertDivisor
    		cont2:
    		
    		xor t4, t5, t4 		#resulting sign is stored in t4
    		slli t4, t4, 31
    		sw t4, 4(t6)		#now the sign is stroed in result
    		
    		beqz t1, divisorIsZero
    		
    		li a2, 999	#length of mantisa
    		
    		li t3, 31	#max num of bits in numerator
    		li a1, 31	#current power of exponential counter
    		
    		
    		li t4, 0	#result
    		li t2, 0	#remainder
    		li a0, 0 	#flag that the exponent has been set
    		#li a7, 0	#marker that the dividend is getting smaller
    		
    		
    		normalDivision:
			#bltz t2 divDone
			beqz a2, divDone
			mv t6, t0
			#slli a3,a3,1
			
		    	sra t6, t6, t3             # Shift the value to the right by 31-0 positions
		    	andi t6, t6, 1              # Extract the least significant bit
		    	
		    	
			slli t2, t2,1		#shift current opperated value to the left by one
			or t2,t2,t6		#add next number from the numerator to the cur op value
			
			slli t4, t4,1		#shift the result of division to the left (does not matter till the exponetial is set)
			#bnez a0, printA2T4rel
			retFrPr:
			addi a2, a2, -1		#decr numb of mant numbs left

			
			blt t2,t1,skipSub	#if the cur op val is still less that the denumerator then skip the substraction and do not add anything to the result
			
			sub t2,t2,t1
			
			beqz a0, setExp		#if the exponent has not been set (which is marked by a0) then do it 
			
			li a4, 1		
			or t4,t4,a4		#add 1 to the result at a designated position
			
		    skipSub:
		    	addi t3, t3, -1		#decrease the t3 counter by 1
			li t6, 2
			

			
			addi a1, a1, -1		#decrease the pow of exp counter by 1	
			
			li t6, 32
			beq a2, t6, updateMantFPart
			upRet:	
			bltz t3, setNumToRem
			j normalDivision
    	

    	printA2T4rel:			#Section that is only used to debug the dependence of a2 and current result value
    		mv t5, a0
    		mv a0, a2
		li a7,1
		ecall
		
		li a0, ' '
		li a7,11
		ecall

		mv a0, t4
		li a7,1
		ecall
		
		li a0, '\n'
		li a7,11
		ecall
		
		mv a0, t5
		
    		j retFrPr
    	
    	divDone:
		la t5, IEEE754_64_rep			#saving of the 2nd part of mantisa
		lw t6, (t5)
		or t6, t6, t4
		sw t6, (t5)

		

	fin:
	
	

		
		la a0, msg_result
		li a7,4
		ecall
		
	
		fld fa0, IEEE754_64_rep, t3
		li a7, 3 # print processed string
		ecall
	
		li a7, 10 # exit
		ecall
		
		
		
		
		
	divisorIsZero:
		la a0, error_msg_DenumIsZero
		li a7, 4
		ecall
		
		li a7, 10 # exit
		ecall
		
		
	invertDividend:
		addi t0, t0, -1
		not t0,t0
		j cont1
		
	invertDivisor:
		addi t1, t1, -1
		not t1,t1
		j cont2
	
	setExp:					#section that sets the exponent part of float
		bnez a0, skipSub	#exp beginning
		li a0, 1
		addi t6,a1 ,1023
		la t5, IEEE754_64_rep
		lw t4, 4(t5)
		slli t6,t6, 20
		or t4, t4, t6
		sw t4 , 4(t5)
		li a2, 52	# more than the true mantisa length to negate the first decrease that folows the return
		li t4, 0

		j skipSub
	setNumToRem:			#if the end of numerator is reached it is just set to 0 and t3 is reset (technically a rudement that can be removed with a skight change in logic of the algorithm)

		li t0,0
		li t3, 31
		j normalDivision
		
		#setNumToZero:
		#	li t0,0
		#	add a2, a2, a7
		#	addi a1, a1, 1
		#	li t3, 31
		#j normalDivision
		
	updateMantFPart:		#saves the first part of mantisa stored in result register to the result address
		la t5, IEEE754_64_rep	#mant upd
		lw t6, 4(t5)
		or t6, t6, t4
		sw t6, 4(t5)
		
		li t4, 0
		
		j upRet
		
.data
    error_msg_DenumIsZero: .asciz "Entered denumerator is ZERO" 
    IEEE754_64_rep:	.double	0 #1234.5678345679	#result address
    denum_req: .ascii "Please enter the denumerator: " 
    #num_req: .ascii "Please enter the numerator: " 
    mantisa_64:	.dword   0
    msg_result: .asciz "The result of the division is: "
    exponential_64: .word 0
    num_req: .ascii "Please enter the numerator: " 

