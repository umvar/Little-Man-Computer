GLOBAL _main

EXTERN _printf
EXTERN _scanf
EXTERN _fopen
EXTERN _fread
EXTERN _fclose
EXTERN _exit

%INCLUDE "Instructions.asm"

SECTION .data
	; Registers
	ACU:	 DW 0			; Accumulator
	PC:	 DW 0			; Program Counter

	; Opcodes
	OP_TABLE:
	DD OP_HLT			; 0xx
	DD OP_ADD, OP_SUB		; 1xx, 2xx
	DD OP_STA, OP_LDA		; 3xx, 4xx
	DD OP_BRA, OP_BRZ, OP_BRP	; 5xx, 6xx, 7xx
	DD OP_NOP, OP_IO		; 8xx, 9xx

	IO_TABLE:
	DD IO_NIO, IO_INP, IO_OUT	; 900, 901, 902

	; Formats
	DecFMT:		DB "%d", 0
	HexFMT:		DB "%x", 0
	WordFMT:	DB "%hd", 0

	; IO Messages
	InpMSG:		DB "Input: ", 0
	OutMSG:		DB "Output: ", 10, 0

	; File
	FileName:	DB "Program.lmc", 0
	Mode:		DB "rb", 0	
	Error:		DB "Cannot open file", 10, 0	

SECTION .bss
	MEM:	RESW 100		;Y Memory (100 words)

SECTION .text
LoadFile:
	PUSH	ebp
	MOV	ebp, esp

	SUB	esp, 0xF

	SUB	esp, 4

	PUSH	dword Mode
	PUSH	dword FileName
	CALL	_fopen
	ADD	esp, 8
	TEST	eax, eax
	JZ	.Error
	MOV	[ebp - 4], eax

	PUSH	dword [ebp - 4]
	PUSH	dword 100
	PUSH	dword 2
	PUSH	dword MEM
	CALL	_fread
	ADD	esp, 16

	PUSH	dword [ebp - 4]
	CALL	_fclose
	ADD	esp, 4


	MOV	esp, ebp
	POP	ebp
	RET

	.Error:
	PUSH	dword Error
	CALL	_printf
	ADD	esp, 4
	PUSH	dword 1
	CALL	_exit

VM:
	GetInstruction:
	MOVZX	eax, word [PC]
	MOV	ax, [MEM + eax*2]

	IncrementPC:
	ADD	word [PC], 1

	; ax = opcode, bx = operand
	DecodeInstruction:
	MOV	ebx, eax
	AND	ax, 0xF
	SHR	bx, 4

	; ecx = function address
	GetFunction:
	MOV	ecx, [OP_TABLE + eax*4]

	Execute:
	CALL	ecx

	NextInstruction:
	CMP	word [PC], 100
	JL	VM
	RET

_main:
	CALL	LoadFile
	CALL	VM
	RET