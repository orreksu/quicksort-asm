
.global main

.text

// --- SWAP ---
/*
    Variable Mappings:
        - xs is %rdi
        - ii is %rsi
        - jj is %rdx
        - tmp is %r10
*/
// void swap(long* xs, long ii, long jj)
swap:
    enter $0, $0

    // if (ii != jj) {
    cmp %rdx, %rsi
    je done_swap_if

    // long tmp = xs[ii];
    mov (%rbx,%rsi,8), %r10

    // xs[ii] = xs[jj];
    mov (%rdi,%rdx,8), %r11
    mov %r11, (%rdi,%rsi,8)

    // xs[jj] = tmp;
    mov %r10, (%rdi,%rdx,8)

    // }
done_swap_if:

    leave
    ret



// --- PARTITION ---
/*
    Varibale Mappings:
        - xs is %rbx
        - lo is %rsi
        - hi is %rdx
        - (hi - 1) is %r12
        - pivot is %r13
        - ii is %r14
        - jj is %r15
*/
// long partition(long* xs, long lo, long hi)
partition:
    push %rbx
    push %r12
    push %r13
    push %r14
    push %r15
    enter $8, $0

    mov %rdi, %rbx
    dec %rdx
    mov %rdx, %r12

    // long pivot = xs[hi - 1];
    mov (%rbx,%r12,8), %r13

    // long ii = lo;
    mov %rsi, %r14

    // long jj = lo;
    mov %rsi, %r15

part_loop:

    // for (; jj < (hi - 1); ++jj) {
    cmp %r12, %r15
    jge done_part_loop

    // if (xs[jj] < pivot) {
    mov (%rbx,%r15,8), %r10
    cmp %r13, %r10
    jge done_part_if

    // swap(xs, ii, jj);
    mov %rbx, %rdi
    mov %r14, %rsi
    mov %r15, %rdx
    call swap

    // ++ii;
    inc %r14

done_part_if:

    // ++jj
    inc %r15

    // }
    jmp part_loop

done_part_loop:

    // swap(xs, ii, hi - 1);
    mov %rbx, %rdi
    mov %r14, %rsi
    mov %r12, %rdx
    call swap

    // return ii;
    mov %r14, %rax

    leave
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret



// --- QUICKSORT ---
/*
    Variable Mappings:
        - xs is %rbx
        - lo is %r12
        - hi is %r13
        - (hi - lo) is %r10
        - pp is %r14
*/
// void quicksort(long* xs, long lo, long hi)
quicksort:
    push %rbx
    push %r12
    push %r13
    push %r14
    enter $0, $0

    mov %rdi, %rbx
    mov %rsi, %r12
    mov %rdx, %r13

    // if (hi - lo < 1) { return; }
    mov %r13, %r10
    sub %r12, %r10
    cmp $1, %r10
    jl end_quicksort

    // long pp = partition(xs, lo, hi);
    mov %rbx, %rdi
    mov %r12, %rsi
    mov %r13, %rdx
    call partition
    mov %rax, %r14

    // quicksort(xs, lo, pp);
    mov %rbx, %rdi
    mov %r12, %rsi
    mov %r14, %rdx
    call quicksort

    // quicksort(xs, pp + 1, hi);
    mov %rbx, %rdi
    inc %r14
    mov %r14, %rsi
    mov %r13, %rdx
    call quicksort

end_quicksort:
    leave
    pop %r14
    pop %r13
    pop %r12
    pop %rbx
    ret



// --- READ_INT ---
/*
    Variable Mappings:
        - ptr is %rdi
        - scanf("%ld", ptr) is %rax
*/
// void read_int(long* ptr)
read_int:
    enter $0, $0
    
    // scanf("%ld", ptr)
    mov %rdi, %rsi
    mov $scan_fmt, %rdi
    mov $0, %al
    call scanf

    // if (scanf("%ld", ptr) != 1) {
    cmp $1, %rax
    je end_read_int

    // puts("bad input");
    mov $bad_input, %rdi
    call puts

    // exit(1);
    mov $0, %rdi
    mov $60, %rax
    syscall

end_read_int:
    leave
    ret



// --- MAIN ---
/*
    Varibale Mapping:
        - nn is %rbx    // size of the data set
        - xs is %r12    // pointer to the array
        - ii is %r13
*/
// int main(int _argc, char* _argv[])
main:
    push %rbx
    push %r12
    push %r13
    enter $8, $0
    
    // long nn;
    lea 0(%rsp), %rbx
    
    // read_int(&nn);
    mov %rbx, %rdi
    call read_int

    // long* xs = malloc(nn * sizeof(long));
    imul $8, (%rbx), %rdi
    call malloc
    mov %rax, %r12

    // for (long ii = 0; ii < nn; ++ii) {
    mov $0, %r13
read_loop:
    cmp (%rbx), %r13
    jge done_read_loop

    // read_int(&(xs[ii]));
    lea (%r12,%r13,8), %rdi
    call read_int

    // ++ii
    inc %r13
    
    // }
    jmp read_loop

done_read_loop:

    // quicksort(xs, 0, nn);
    mov %r12, %rdi
    mov $0, %rsi
    mov (%rbx), %rdx
    call quicksort

    // printf("%ld\n", nn);
    mov $print_nl_fmt, %rdi
    mov (%rbx), %rsi
    mov $0, %al
    call printf
    
    // for (long ii = 0; ii < nn; ++ii) {
    mov $0, %r13
print_loop:
    cmp (%rbx), %r13
    jge done_print_loop

    // printf("%ld ", xs[ii]);
    mov $print_sp_fmt, %rdi
    mov (%r12,%r13,8), %rsi
    mov $0, %al
    call printf

    // ++ii
    inc %r13

    // }
    jmp print_loop

done_print_loop:

    // printf("\n");
    mov $new_line, %rdi
    mov $0, %al
    call printf

    // free(xs);
    mov %r12, %rdi
    call free

    // return 0;
    mov $0, %rax

    leave
    pop %r13
    pop %r12
    pop %rbx
    ret


.data
bad_input: .string "bad input"
scan_fmt: .string "%ld"
print_nl_fmt: .string "%ld\n"
print_sp_fmt: .string "%ld "
new_line: .string "\n"
