.data
# Training data: x, y, label (3 samples)
train_data:
    .word 1, 2, 0          # Sample 0: (1,2) label 0
    .word 2, 9, 1          # Sample 1: (2,9) label 1
    .word 6, 7, 1          # Sample 2: (6,7) label 1

# Test point
test_data:
    .word 3, 3

# Interleaved (distance, label)
dist_label_pairs:
    .word 0, 0, 0, 0, 0, 0

# Label votes (assumes only 2 labels: 0 and 1)
label_votes:
    .word 0, 0

# Output
predicted_label:
    .word 0

.text
.globl main

main:
    li x4, 3                  # x4 = k = 3
    la x5, test_data
    lw x6, 0(x5)              # x6 = test_x
    lw x7, 4(x5)              # x7 = test_y

    la x8, train_data         # x8 = training data base
    la x9, dist_label_pairs   # x9 = output (dist,label) pair base
    li x10, 3                 # x10 = number of samples
    li x11, 0                 # x11 = loop index

# Distance loop
loop_dist:
    slli x12, x11, 2
    slli x13, x11, 3
    add x12, x12, x13         # x12 = offset = i * 12
    add x14, x8, x12          # x14 = address of current sample

    lw x15, 0(x14)            # x15 = train_x
    lw x16, 4(x14)            # x16 = train_y
    lw x17, 8(x14)            # x17 = label

    sub x18, x15, x6
    mul x19, x18, x18         # x19 = dx²

    sub x20, x16, x7
    mul x21, x20, x20         # x21 = dy²

    add x22, x19, x21         # x22 = distance²

    sw x22, 0(x9)             # store distance
    sw x17, 4(x9)             # store label
    addi x9, x9, 8            # move to next pair

    addi x11, x11, 1
    blt x11, x10, loop_dist

# Bubble sort
la x23, dist_label_pairs      # x23 = base
li x24, 3                     # x24 = count
li x25, 0                     # i = 0 outer loop

sort_outer:
    li x26, 0                 # j = 0 inner
    addi x27, x24, -1         # x27 = limit = n-1

sort_inner:
    slli x28, x26, 3
    add x29, x23, x28         # addr = base + j*8
    lw x30, 0(x29)            # dist_j
    lw x31, 4(x29)            # label_j
    lw x12, 8(x29)            # dist_j+1
    lw x13, 12(x29)           # label_j+1

    bge x30, x12, do_swap
no_swap:
    addi x26, x26, 1
    addi x27, x27, -1
    bgtz x27, sort_inner
    addi x25, x25, 1
    addi x24, x24, -1
    bgtz x24, sort_outer
    j vote_k

do_swap:
    sw x12, 0(x29)
    sw x13, 4(x29)
    sw x30, 8(x29)
    sw x31, 12(x29)
    j no_swap

# Voting
vote_k:
    la x5, dist_label_pairs
    la x6, label_votes
    li x7, 0                 # index

vote_loop:
    slli x8, x7, 3
    add x9, x5, x8
    lw x10, 4(x9)            # label = pair[i].label

    slli x11, x10, 2
    add x12, x6, x11
    lw x13, 0(x12)
    addi x13, x13, 1
    sw x13, 0(x12)

    addi x7, x7, 1
    blt x7, x4, vote_loop

# Get max voted label
    lw x14, 0(x6)           # label 0 vote count
    lw x15, 4(x6)           # label 1 vote count
    li x16, 0
    bge x14, x15, store_final
    li x16, 1

store_final:
    la x17, predicted_label
    sw x16, 0(x17)

end:
    j end
