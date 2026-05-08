        .text
        .align  1
        .globl  bubblesort
        .type   bubblesort, @function
bubblesort:
        # a0 = arr (int*), a1 = n
        # 寄存器分配：
        #   t0 = i (外层下标)
        #   t1 = j (内层下标)
        #   t2 = n - 1
        #   t3 = n - 1 - i (内层上界)
        addi    t2, a1, -1          # t2 = n - 1
        li      t0, 0               # i = 0
.L_outer:
        bge     t0, t2, .L2         # i >= n-1 时跳出
        sub     t3, t2, t0          # t3 = n - 1 - i
        li      t1, 0               # j = 0
.L_inner:
        bge     t1, t3, .L_inc_i    # j >= n-1-i 时跳出内层
        slli    t4, t1, 2           # t4 = j * 4 (int 是 4 字节)
        add     t5, a0, t4          # t5 = &arr[j]
        lw      t6, 0(t5)           # t6 = arr[j]
        lw      a2, 4(t5)           # a2 = arr[j+1]
        ble     t6, a2, .L_inc_j    # 升序排好则跳过交换
        sw      a2, 0(t5)           # arr[j]   = old arr[j+1]
        sw      t6, 4(t5)           # arr[j+1] = old arr[j]
.L_inc_j:
        addi    t1, t1, 1
        j       .L_inner
.L_inc_i:
        addi    t0, t0, 1
        j       .L_outer
.L2:
        li      a0, 0               # 返回 0 (调用方借此初始化循环变量 i)
        ret
        .size   bubblesort, .-bubblesort
