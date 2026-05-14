.align 2
.section .data
.section .text
.global __aeabi_memclr4
__aeabi_memclr4:
.L1:
		MV	t5, a0
		MV	t6, a1
		ADD	t6, a0, t6
		LI	a0, 0
.L2:
		SW	zero, (t5)
		ADDI	t5, t5, 4
		BLT	t5, t6, .L2
		RET
.global gcd
gcd:
.L3:
		ADDI	sp, sp, -240
		SD	fp, 40(sp)
		ADDI	fp, sp, 240
		SD	ra, -208(fp)
		SD	s2, -216(fp)
		SD	s3, -224(fp)
		SD	s4, -232(fp)
		SD	s5, -240(fp)
.L4:
		SW	a0, -192(fp)
		SW	a1, -184(fp)
		LW	s2, -192(fp)
		LW	s3, -184(fp)
		SUB	t6, s2, s3
		SEQZ	s4, t6
		SW	a0, (fp)
		SW	a1, 8(fp)
		SW	s2, -24(fp)
		SW	s3, -32(fp)
		SW	s4, -40(fp)
		LW	s2, -40(fp)
		BGTZ	s2, .L5
		J	.L6
.L7:
		LW	s3, -176(fp)
		SW	s2, -40(fp)
		SW	s3, -48(fp)
		LW	a0, -48(fp)
		LD	s5, -240(fp)
		LD	s4, -232(fp)
		LD	s3, -224(fp)
		LD	s2, -216(fp)
		LD	ra, -208(fp)
		LD	fp, -200(fp)
		ADDI	sp, sp, 240
		RET
.L5:
		LW	s2, -192(fp)
		SW	s2, -176(fp)
		SW	a0, -48(fp)
		SW	s2, -64(fp)
		J	.L7
.L6:
		LW	s2, -192(fp)
		LW	s3, -184(fp)
		SLT	s4, s3, s2
		SW	s2, -72(fp)
		SW	s3, -80(fp)
		SW	s4, -88(fp)
		LW	s2, -88(fp)
		BGTZ	s2, .L8
		J	.L9
.L8:
		LW	s3, -192(fp)
		LW	s4, -184(fp)
		SW	s2, -88(fp)
		SUB	s2, s3, s4
		LW	s5, -184(fp)
		ADDI	sp, sp, -32
		SW	s2, -112(fp)
		LW	a0, -112(fp)
		SW	s5, -120(fp)
		LW	a1, -120(fp)
		CALL	gcd
		ADDI	sp, sp, 32
		SW	a0, -128(fp)
		LW	s2, -128(fp)
		SW	s2, -176(fp)
		SW	a0, -112(fp)
		SW	a1, -120(fp)
		SW	s2, -128(fp)
		SW	s3, -96(fp)
		SW	s4, -104(fp)
		J	.L7
.L9:
		LW	s2, -184(fp)
		LW	s3, -192(fp)
		SUB	s4, s2, s3
		LW	s5, -192(fp)
		ADDI	sp, sp, -32
		SW	s4, -152(fp)
		LW	a0, -152(fp)
		SW	s5, -160(fp)
		LW	a1, -160(fp)
		CALL	gcd
		ADDI	sp, sp, 32
		SW	a0, -168(fp)
		SW	s2, -136(fp)
		LW	s2, -168(fp)
		SW	s2, -176(fp)
		SW	a0, -152(fp)
		SW	a1, -160(fp)
		SW	s2, -168(fp)
		SW	s3, -144(fp)
		J	.L7
.global main
main:
.L10:
		ADDI	sp, sp, -144
		SD	fp, 40(sp)
		ADDI	fp, sp, 144
		SD	ra, -112(fp)
		SD	s2, -120(fp)
		SD	s3, -128(fp)
		SD	s4, -136(fp)
		SD	s5, -144(fp)
.L11:
		ADDI	sp, sp, -16
		CALL	getint
		ADDI	sp, sp, 16
		SW	a0, -8(fp)
		LW	s2, -8(fp)
		SW	s2, -88(fp)
		ADDI	sp, sp, -16
		CALL	getint
		ADDI	sp, sp, 16
		SW	a0, -24(fp)
		LW	s3, -24(fp)
		SW	s3, -80(fp)
		LW	s4, -88(fp)
		LW	s5, -80(fp)
		ADDI	sp, sp, -32
		SW	s4, -40(fp)
		LW	a0, -40(fp)
		SW	s5, -48(fp)
		LW	a1, -48(fp)
		CALL	gcd
		ADDI	sp, sp, 32
		SW	a0, -56(fp)
		ADDI	sp, sp, -16
		SW	a0, -40(fp)
		LW	a0, -56(fp)
		CALL	putint
		ADDI	sp, sp, 16
		ADDI	sp, sp, -16
		SW	a0, -56(fp)
		LI	a0, 10
		CALL	putch
		ADDI	sp, sp, 16
		LI	t0, 0
		SW	t0, -96(fp)
		SW	a1, -48(fp)
		SW	s2, -8(fp)
		SW	s3, -24(fp)
		J	.L12
.L12:
		LW	s2, -96(fp)
		SW	s2, -72(fp)
		LW	a0, -72(fp)
		LD	s5, -144(fp)
		LD	s4, -136(fp)
		LD	s3, -128(fp)
		LD	s2, -120(fp)
		LD	ra, -112(fp)
		LD	fp, -104(fp)
		ADDI	sp, sp, 144
		RET

