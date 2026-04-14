.section .rodata
filename:    .string "input.txt"
yes_str:     .string "Yes\n"
no_str:      .string "No\n"

.section .bss
# We need two tiny 1-byte buffers to hold the characters we're comparing
buf_left:    .space 1
buf_right:   .space 1

.text
.globl main

main:
    li a0,-100       #Tells Linux to look in the current folder
    la a1,filename      #point to input.txt
    li a2, 0                     # Open for reading only
    li a3, 0                     # No special mode flags needed
    li a7, 56                    # System call 56 is 'openat'
    ecall

    bltz a0,error_exit      # If the file descriptor in a0 is negative, something went wrong
    mv s0,a0

    mv a0,s0
    li a1,0
    li a2,2            
    li a7,62        # System call 62 is 'lseek'
    ecall
    mv s1,a0        # a0 now holds the total file size. Save it in s1.

    beqz s1,print_yes       #empty file is size 0 that is a palindrome

    li s2,0     #s2 is left pointer startign from 0
    addi s3,s1,-1   #s3 is the right pointer 

loop:
    bge s2,s3,print_yes #if left pointer has crossed right pointer that means no mistkake has been found that it is a palindrome

    mv a0,s0        
    mv a1,s2    #current left
    li a2,0     #Move  to this exact spot from the start
    li a7,62        #lseek
    ecall

    mv a0,s0
    la a1,buf_left      # Place the character into our left buffer
    li a2,1     #need 1 byte
    li a7,63        #system call 63 is read
    ecall

    mv a0, s0
    mv a1, s3                    # Current right position
    li a2, 0                     # SEEK_SET: Move cursor to this exact spot
    li a7, 62                    # lseek
    ecall

    mv a0,s0
    la a1,buf_right  #place character into right buffer
    li a2,1
    li a7,63        #read
    ecall

    la t0,buf_left
    lb t1,0(t0)     #load the actual left char
    la t0, buf_right
    lb t2, 0(t0)                 # Load the actual right char into t2

    bne t1,t2,print_no      #if they do not match it is not a palindrome we dont need to check further 
    addi s2,s2,1        #move the left pointer to left
    addi s3,s3,-1       #move the right pointer
    j loop

print_yes:
    li a0,1
    la a1,yes_str
    li a2,4     #length of "Yes\n"
    li a7,64        #system call for write
    ecall
    j exit_program

print_no:
     li a0,1
    la a1,no_str
    li a2,3    #length of "No\n"
    li a7,64        #system call for write
    ecall
    j exit_program

error_exit:
    # If the file couldn't open, we just jump to the end
    j exit_program

exit_program:
    mv a0,s0
    li a7,57        #system csll for close
    ecall

    li a0,0
    li a7,93            #system call for exit
    ecall







