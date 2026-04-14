.data

.text
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)

    mv s0,a0     
    li a0,12
    call malloc

    beq a0,x0,endoffunc

    sw s0,0(a0)         #store val
    sw x0,4(a0)         #left pointer=NULL
    sw x0,8(a0)        #right pointer=NULL       

endoffunc:
    lw s0,8(sp)
    lw ra,12(sp)
    addi sp,sp,16
    ret

insert:
    addi sp,sp,-16
    sw ra,12(sp)                 #storing return address
    sw s0,8(sp)                 #storing left ppinter
    sw s1,4(sp)                #storing right pointer

    mv s0,a0                    #storing root value in s0
    mv s1,a1                    #storing  val in s1

    beq s0,x0,insert_create     #if root==NULL then we have to call make_node function with value=val
    lw t0,0(s0)
    blt s1,t0,insert_left       #if val is less than value of root calling insert left function


insert_right:
    lw a0,8(s0)        #taking root->right and putting it in a0
    mv a1,s1            #putting val in a1
    call insert          #again calling the function(recursion)
    sw a0,8(s0)        #taking the pointer to root->right
    mv a0,s0            #storing root value to original pointer
    j insert_end


insert_left:
    lw a0,4(s0)         #taking root->left and putting it in a0
    mv a1,s1            #putting val in a1
    call insert          #again calling the function(recursion)
    sw a0,4(s0)         #taking the pointer to root->left
    mv a0,s0            #storing root value to original pointer
    j insert_end


insert_create:
    mv a0,s1            #creating a new node function with now the argument having value as val
    call make_node      #calling make node function
    j insert_end        

insert_end:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

get:
    addi sp,sp,-16
    sw ra,12(sp)         # storing return address
    sw s0,8(sp)          # storing root pointer      
    sw s1,4(sp)         # storing value to search

    mv s0,a0        #storing root pointer value in s0
    mv s1,a1        #sotring val in s1

    beq s0,x0,get_null       # if root == NULL return NULL
    lw t0,0(s0)              # loading root->val into t0
    blt s1,t0,get_left      # if val < root->val go left
    beq s1,t0,get_found     # if val == root->val return node

get_right:
    lw a0,8(s0)        # taking root->right and putting it in a0
    mv a1,s1        # putting val in a1
    call get         # recursive call on right subtree
    j get_end        # jump to end

get_left:
   lw a0,4(s0)             # taking root->left and putting it in a0
    mv a1,s1                # putting val in a1
    call get                # recursive call on left subtree
    j get_end               # jump to end

get_found:
    mv a0,s0     # return current node pointer
    j get_end        # jump to end

get_null:
    li a0,0      # return NULL
    j get_end

get_end:
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret

getAtMost:
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)
    sw s1,4(sp)

    mv s0,a1
    mv s1,a0
    li t1,-1        #answer = -1(if no value is found given in the question)
getAtMost_loop:
    beq s0,x0,getAtMost_completed       # if root == NULL, stop loop
    lw t0,0(s0)
    ble t0,s1,getAtMost_updateans       # if node->val <= val update answer
    lw s0,4(s0)     # go to left subtree (values are smaller)
    j getAtMost_loop         # repeat loop

getAtMost_updateans:
    mv t1,t0         # updating answer with current node value
    lw s0,8(s0)         # go to right subtree (trying to find larger valid value)
    j getAtMost_loop

getAtMost_completed:
    mv a0,t1          # return answer
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret

