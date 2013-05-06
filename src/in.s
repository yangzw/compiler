	.file	"in.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-8, %esp
	subl	$32, %esp
	movl	$0, 8(%esp)
	addl	$1, 8(%esp)
	movl	$15, %eax
	subl	8(%esp), %eax
	movl	%eax, 16(%esp)
	fldl	.LC0
	fstpl	24(%esp)
	movl	$2, 12(%esp)
	movl	$6, 20(%esp)
	movl	8(%esp), %eax
	cmpl	12(%esp), %eax
	jle	.L2
	cmpl	$0, 8(%esp)
	jle	.L3
.L2:
	cmpl	$4, 12(%esp)
	jle	.L4
.L3:
	movl	12(%esp), %eax
	movl	%eax, 8(%esp)
	cmpl	$2, 8(%esp)
	jg	.L6
	movl	$3, 8(%esp)
	jmp	.L6
.L7:
	addl	$1, 8(%esp)
.L6:
	cmpl	$3, 8(%esp)
	jle	.L7
.L4:
	addl	$1, 8(%esp)
	movl	8(%esp), %eax
	cmpl	12(%esp), %eax
	jg	.L8
	cmpl	$3, 12(%esp)
	jle	.L9
.L8:
	addl	$1, 8(%esp)
	addl	$1, 12(%esp)
	jmp	.L10
.L9:
	subl	$1, 8(%esp)
	subl	$1, 12(%esp)
	jmp	.L11
.L12:
	addl	$1, 8(%esp)
.L11:
	cmpl	$9, 8(%esp)
	jle	.L12
.L10:
	movl	12(%esp), %eax
	movl	%eax, 8(%esp)
	movl	$2, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.section	.rodata
	.align 8
.LC0:
	.long	-858993459
	.long	-1073165108
	.ident	"GCC: (Ubuntu/Linaro 4.7.2-2ubuntu1) 4.7.2"
	.section	.note.GNU-stack,"",@progbits
