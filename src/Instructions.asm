; ax = opcode, bx = operand

; LMC ends program ;
OP_HLT:
	MOV	word [PC], 100
	RET

; Add ACU with value at address xx ;
OP_ADD:
	MOV	cx, [MEM + ebx*2]
	ADD	word [ACU], cx
	RET

; Subtract ACU with value at address xx ;
OP_SUB:
	MOV	cx, [MEM + ebx*2]
	SUB	word [ACU], cx
	RET

; Store ACU into address xx ;
OP_STA:
	MOV	cx, [ACU]
	MOV	word [MEM + ebx*2], cx
	RET

; Load value from address xx into ACU ;
OP_LDA:
	MOV	cx, [MEM + ebx*2]
	MOV	word [ACU], cx
	RET

; Set PC to address xx ;
OP_BRA:
	MOV	word [PC], bx
	RET

; If ACU = 0, Set PC to address xx ;
OP_BRZ:
	CMP	word [ACU], 0
	JE	OP_BRA
	RET

; If ACU >= 0, Set PC to address xx ;
OP_BRP:
	CMP	word [ACU], 0
	JGE	OP_BRA
	RET

; Do nothing ;
OP_NOP:
	RET

; Input & Output ;
OP_IO:
	MOV	eax, [IO_TABLE + ebx*4]
	JMP	eax

; No IO Instruction
IO_NIO:
	RET

; ACU = INP 
IO_INP:	
	PUSH	dword InpMSG
	CALL	_printf
	ADD	esp, 4
	PUSH	dword ACU
	PUSH	dword WordFMT
	CALL	_scanf
	ADD		esp, 8
	RET

; OUT = ACU
IO_OUT:
	MOVZX	eax, word [ACU]
	PUSH 	eax
	PUSH	dword DecFMT	
	CALL	_printf
	ADD	esp, 8
	RET