.data
space: .asciz " "
newline: .asciz "\n"

.text
.globl main
main:
    addi t0,a0,-1       #subtracting 1 so that now t0 has the value n
    blez t0,end    #if no arguments givne then we go to end

    mv s0,t0        #s0 will have value n
    mv s1,a1        #s1 will have the base address of argv

    slli t1,s0,2    #total bytes needed for int array

    li a7,9         #
    mv a0,t1
    ecall
    mv s2,a0        #base address of input array

    li a7,9
    mv a0,t1
    ecall
    mv s3,a0    #result arrays

    li a7,9
    mv a0,t1
    ecall
    mv s4,a0    #stack

    li t2,1     #argv index (start at 1 to skip ./a.out)
    li t3,0     #t3 is arr index

parse:
    bge t3, s0, init_res        # If arr index >= n, parsing is done

    slli t4, t2, 3      # Multiply argv index by 8
    add t4, s1, t4      # Add offset to argv base address
    lw a0, 0(t4)        # Load the 8-byte string pointer into a0

    jal ra, atoi_s      # Jump to string-to-integer subroutine

    slli t5, t3, 2      # Multiply arr index by 4
    add t5, s2, t5      # Add offset to arr base address
    sw a0, 0(t5)        # Store the parsed integer into arr[i]

    addi t2, t2, 1      # Increment argv index
    addi t3, t3, 1      # Increment arr index
    j parse             #call loop agin

init_res:
    li t0,0     #i=0
loop:
    bge t0,s0,evaluate      # If i >= n, done initializing
    slli t1,t0,2        # i * 4
    add t1,s3,t1        # Offset + result base addres
    li t2,-1        # Load -1
    sw t2,0(t1)     # result[i] = -1
    addi t0,t0,1        #i++
    j loop

evaluate:
    li s5,0     #s5 = stack size
    mv t0,s0        #i=n
    addi t0,t0,-1

loop_i:
    bltz t0,output

check_stack:
    beqz s5,insert      # If stack size is 0, skip while-loop logic and we will push it to stack
    addi t1,s5,-1       # t1 = stack size - 1 
    slli t1, t1, 2      # Multiply by 4 for byte offset
    add t1, s4, t1      # Add to stack base address
    lw t2, 0(t1)

    slli t3, t2, 2      # Multiply that index by 4
    add t3, s2, t3      # Add to arr base address
    lw t4, 0(t3)

    slli t5, t0, 2
    add t5, s2, t5
    lw t6, 0(t5)

    ble t4, t6, removetop       #If arr[stack.top()] <= arr[i], branch to pop the stack

     slli t3, t0, 2
    add t3, s3, t3      # Add to result base address
    sw t2, 0(t3)        # result[i] = stack.top()
    j insert

removetop:
    addi s5,s5,-1       # stack.pop() (Decrease stack size by 1)
    j check_stack       # Repeat the while loop condition

insert:
     slli t1, s5, 2     # stack size * 4
    add t1, s4, t1      # Add to stack base address
    sw t0, 0(t1)        #save the current i into stack

    addi s5, s5, 1      # Increase stack size by 1
    addi t0, t0, -1
    j loop_i

output:
    li t0,0     # i = 0

print_loop:
    bge t0,s0,end       # If i >= n, we are done printing

    slli t1, t0, 2
    add t1, s3, t1
    lw a0, 0(t1)        # Load result[i] into a0

    li a7, 1        # Syscall 1: Print integer
    ecall

     li a7, 4       # Syscall 4: Print string
    la a0, space        # address of space character
    ecall

    addi t0, t0, 1
    j print_loop

end:
     li a7, 4
    la a0, newline
    ecall

    li a7, 10
    ecall

atoi_s:
    li t0, 0

atoi_loop:
     lb t1, 0(a0)
    beqz t1, atoi_done

    addi t1, t1, -48
    li t2, 10
    mul t0, t0, t2
    add t0, t0, t1

    addi a0, a0, 1
    j atoi_loop

atoi_done:
    mv a0,t0
    ret







