.section .rodata
int_fmt:      .string "%d"
space_str:    .string " "
newline_str:  .string "\n"

.text
.globl main

main:
  
    # Allocate 80 bytes to save registers and maintain 16-byte alignment
    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)       # n (argc - 1)
    sd s1, 56(sp)       # pointer to input array
    sd s2, 48(sp)       # pointer to result array
    sd s3, 40(sp)       # pointer to stack base
    sd s4, 32(sp)       # stack top index
    sd s5, 24(sp)       # loop counter i
    sd s6, 16(sp)       # argv base pointer

   
    addi s0, a0, -1     # n = argc - 1
    mv s6, a1           # Save argv pointer
    
    # If n <= 0, exit
    blez s0, exit_prog

   
    slli a0, s0, 2      # bytes = n * 4
    call malloc
    mv s1, a0           # s1 = arr[]

    slli a0, s0, 2
    call malloc
    mv s2, a0           # s2 = result[]

    slli a0, s0, 2
    call malloc
    mv s3, a0           # s3 = helper stack[]
    li s4, 0            # stack size = 0

   
    li s5, 0            # i = 0
parse_loop:
    bge s5, s0, init_res
    addi t0, s5, 1      # argv index = i + 1
    slli t1, t0, 3      # 8-byte pointer offset for 64-bit
    add t1, s6, t1
    ld a0, 0(t1)        # Load string pointer
    call atoi           # Standard C atoi
    
    slli t1, s5, 2      # 4-byte int offset
    add t1, s1, t1
    sw a0, 0(t1)        # Store in arr[i]
    addi s5, s5, 1
    j parse_loop

  
init_res:
    li s5, 0
init_loop:
    bge s5, s0, evaluate
    slli t0, s5, 2
    add t0, s2, t0
    li t1, -1
    sw t1, 0(t0)
    addi s5, s5, 1
    j init_loop

   
evaluate:
    addi s5, s0, -1     # i = n - 1 (backwards)
algo_loop:
    bltz s5, print_results

check_stack:
    beqz s4, insert     # if stack empty, push i
    
    # arr[stack.top()]
    addi t1, s4, -1     # top index
    slli t1, t1, 2
    add t1, s3, t1
    lw t2, 0(t1)        # t2 = stack.top() (index)
    
    slli t3, t2, 2
    add t3, s1, t3
    lw t0, 0(t3)        # t0 = arr[stack.top()]

    # arr[i]
    slli t4, s5, 2
    add t4, s1, t4
    lw t4, 0(t4)        # t4 = arr[i]

    bgt t0, t4, found_greater
    addi s4, s4, -1     # pop
    j check_stack

found_greater:
    slli t3, s5, 2
    add t3, s2, t3
    sw t2, 0(t3)        # result[i] = stack.top() index

insert:
    slli t1, s4, 2
    add t1, s3, t1
    sw s5, 0(t1)        # stack[s4] = i
    addi s4, s4, 1      # size++
    addi s5, s5, -1     # i--
    j algo_loop

   
print_results:
    li s5, 0
print_loop:
    bge s5, s0, exit_prog
    
    # Print space before items except the first
    beqz s5, no_space
    la a0, space_str
    call printf

no_space:
    slli t0, s5, 2
    add t0, s2, t0
    lw a1, 0(t0)        # Argument 2 for printf
    la a0, int_fmt      # Argument 1 for printf
    call printf
    
    addi s5, s5, 1
    j print_loop

exit_prog:
    la a0, newline_str
    call printf

    
    li a0, 0            # return 0
    ld ra, 72(sp)
    ld s0, 64(sp)
    ld s1, 56(sp)
    ld s2, 48(sp)
    ld s3, 40(sp)
    ld s4, 32(sp)
    ld s5, 24(sp)
    ld s6, 16(sp)
    addi sp, sp, 80
    ret