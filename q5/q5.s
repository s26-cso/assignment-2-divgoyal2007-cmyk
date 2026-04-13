.data
filename:   .asciz "input.txt"      # Just telling the assembler the files name
yes_str:    .asciz "Yes\n"          # The string we'll print if the file is a palindrome
no_str:     .asciz "No\n"           # The string we'll print if it is not a palindrome
buf_left:   .space 1                # A tiny 1-byte memory spot to hold the char from the left side
buf_right:  .space 1                # Another tiny 1-byte memory spot for the right side char

.text
.globl main                      # Exposing our starting point for the linker.

main:
    la a0, filename                 # Load the address of our filename into a0 
    li a1, 0                        # Set flag to 0, which means "Read Only" mode
    li a2, 0                        # Mode isn't really needed for just reading, set to 0
    li a7, 1024                     # System call 1024 is for 'open' in RARS/Venus
    ecall                           # Hey OS, please open the file for me
    mv s0, a0                       # Save the file descriptor (our file ticket) into s0 safely

     mv a0, s0                       # Put our file descriptor in a0.
    li a1, 0                        # Offset is 0 because we just want the very end.
    li a2, 2                        # 2 means go to the end of the file.
    li a7, 62                       # System call 62 is 'lseek' (move our reading cursor).
    ecall                           # Hey OS, jump to the end and tell me where we are!
    mv s1, a0                       # Save the file size (length) into s1.
    beqz s1, print_yes              # If the file size is 0, an empty string is technically a palindrome!

    li s2,0                     #s2 is left pointer starting at 0
    addi s3,s1,-1               #s3 is right pointer starting at n-1

loop:
    bge s2,s3,print_yes         #if left index becomes greater than right index that means we have checked everything and no mistake has been found so far hence it is a palindrome

    mv a0,s0        #giving the os our file descriptor
    mv a1,s2        #telling we want to go to the current left index
    li a2,0
    li a7,62
    ecall

    mv a0,s0        # File descriptor in a0 for reading
    la a1,buf_left      # Tell it to put the data into our left buffer
    li a2,1             # We only want to read exactly 1 byte
    li a7,63        # System call 63 is read
    ecall           # Actually collect that buyte from file

    mv a0,s0        #file desciptor in a0
    mv a1,s3        #telling we want to go to the current right index
    li a2,0
    li a7,62
    ecall       # Move the cursor to the right index.

    mv a0, s0                       # File descriptor in a0 for reading
    la a1, buf_right               # Put the data into our 'right' buffer
    li a2, 1                    # Read exactly 1 byte
    li a7, 63                    # read system call
    ecall                          # Grab the byte

    la t0, buf_left                 # Get the memory address of the left buffer
    lb t1, 0(t0)                    # Load that actual byte (character) into register t1
    la t0, buf_right              # Get the memory address of the right buffer
    lb t2, 0(t0)                   # Load that actual byte (character) into register t2

    bne t1,t2,print_no
    
    addi s2,s2,1            #move left pointer
    addi s3,s3,-1           #move right pointer
    j loop

print_yes:
    li a0,1
    la a1,yes_str
    li a2,4     # The string "Yes\n" is exactly 4 bytes long
    li a7,64        #system call 64 is write
    ecall        #print it to screen
    j exit_program

print_no:
    li a0,1
    la a1,no_str
    li a2,3     # The string "No\n" is exactly 4 bytes long
    li a7,64        #system call 64 is write
    ecall       #print it to screen
    j exit_program

exit_program:
    mv a0,s0        #put file descriptor in a0
    li a7,57        #system call 57 is close
    ecall

    li a0,0
    li a7,93    #system call 93 is exit
    ecall


