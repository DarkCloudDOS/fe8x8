Unit XMode;

{$G+,X+,O+,D+,L+,S-}

Interface

Const
  MaxX		= 320;
  MaxY		= 240;
  WidthBytes	= MaxX div 4;

  Page0		= WidthBytes*MaxY*0;
  Page1		= WidthBytes*MaxY*1;
  Page2		= WidthBytes*MaxY*2;

{$IFNDEF VER70}
Const
  Seg0040: Word =  $0040;
  SegA000: Word =  $A000;
  SegB000: Word =  $B000;
  SegB800: Word =  $B800;
{$ENDIF}

Procedure SetXMode;
Procedure ClearScreen( Color: Byte );
Procedure PutPixel( x,y: Integer; Color: Byte );
Function  GetPixel( x,y: Integer ): Byte;

Procedure InitFlip;
Procedure DoneFlip;
Procedure FlipPage( Source, Destination: Word );
Procedure Flip( PFrom,PX1,PY1,PX2,PY2,PTo,XT,YT : Word);

Procedure ShowFrom ( Offset: Word );
Procedure ShowPage ( Page  : Byte );
Procedure WriteFrom( Offset: Word );
Procedure WritePage( Page  : Byte );

Implementation

Var
  SFrom		: Word;
  WFrom		: Word;

Procedure SetXMode;Assembler;
Asm
	MOV 	AX, 	13h
	INT 	10h

	MOV 	DX, 	03C4h
	MOV 	AX, 	0604h
	OUT 	DX, 	AX	 {PORTW[$3C4]:= $0604}
	MOV 	AX, 	0100h
	OUT 	DX, 	AX       {PORTW[$3C4]:= $0100}
	MOV 	DX, 	03C2h
	MOV 	AL, 	0E3h
	OUT 	DX, 	AL       {PORT[$3C2]:= $E3}
	MOV 	DX, 	03C4h
	MOV 	AX, 	0300h
	OUT 	DX, 	AX       {PORTW[$3C4]:= $0300}
	MOV 	DX, 	03D4h
	MOV 	AL, 	$11
	OUT 	DX, 	AL       {PORT[$3D4]:= $11}
	INC 	DX
	IN  	AL,	DX
	AND	AL,	$7F
	OUT	DX, 	AL       {PORT[$3D5]:= PORT[$3D4] AND $7F}
	DEC	DX
	CLD
	MOV	AX, 	0D06h
	OUT	DX, 	AX       {PORTW[$3D4]:= $0D06}
	MOV	AX, 	3E07h
	OUT	DX, 	AX       {PORTW[$3D4]:= $3E07}
	MOV	AX, 	4109h
	OUT	DX, 	AX       {PORTW[$3D4]:= $4109}
	MOV	AX, 	0EA10h
	OUT	DX, 	AX       {PORTW[$3D4]:= $EA10}
	MOV	AX, 	0AC11h
	OUT	DX, 	AX       {PORTW[$3D4]:= $AC11}
	MOV	AX, 	0DF12h
	OUT	DX, 	AX	 {PORTW[$3D4]:= $DF12}
	MOV	AX, 	0014h
	OUT	DX, 	AX	 {PORTW[$3D4]:= $0014}
	MOV	AX, 	0E715h
	OUT	DX, 	AX	 {PORTW[$3D4]:= $E715}
	MOV	AX, 	0616h
	OUT	DX, 	AX	 {PORTW[$3D4]:= $0616}
	MOV	AX,	0E317h
	OUT	DX,	AX	 {PORTW[$3D4]:= $E317}

	MOV     DX,     03C4H
	MOV     AX,     0F02H
	OUT     DX,     AX       {PORTW[$3C4]:= $0F02}

	MOV	AX, 	SegA000  {FILLCHAR(PTR(SEGA000,0)^,$FFFF,0)}
	MOV	ES, 	AX
	XOR 	DI, 	DI
	MOV 	CX, 	0FFFFh/4
	DB  	66h
	XOR 	AX, 	AX	 {XOR EAX,EAX}
	DB  	66h
	REP 	STOSW            {STOSL}
End;

Procedure ClearScreen( Color: Byte ); Assembler;
Asm
     {Selecting all four planes}
	MOV	AX,	0F02H
	MOV	DX,	03C4H
	OUT	DX,	AX	{PORTW[$3C4]:= $0F02;}
     {Fill the screen with the color}
	MOV	AL,	Color
	MOV	AH,	AL
	DB	$66
	SHL	AX,	16
	MOV	AL,	Color
	MOV	AH,	AL

	MOV	ES,	SegA000
	MOV	DI,	WFrom
	MOV	CX,	MaxY*WidthBytes/4
	REP
	DB	$66
	STOSW			{STOSD}
End;

Procedure PutPixel( x,y: Integer; Color: Byte ); Assembler;
Asm
  { Each address accesses four neighboring pixels, so set
    Write Plane Enable according to which pixel we want
    to modify.  The plane is determined by the two least
    significant bits of the x-coordinate: }
	MOV	CX,	X
	AND	CX,	3
	MOV	AL,	1
	SHL	AX,	CL
	MOV	DX,	03C5H
	OUT	DX,	AL

  { The offset of the pixel into the video segment is
    offset = (width * y + x) / 4, and write the given
    color to the plane we selected above.  Heed the active
    page start selection. }
	MOV	DI,	Y
	MOV	DX,	DI
	SHL	DI,	6
	SHL	DX,	4
	ADD	DI,	DX	{Y*80}

	MOV	AX,	X
	SHR	AX,	2       {X/4}
	ADD	DI,	AX
	ADD	DI,	WFrom

	MOV	ES,	SegA000
	MOV	AL,	Color
	MOV	ES:[DI],AL
End;

Function  GetPixel( x,y: Integer ): Byte; Assembler;
Asm
	MOV	AL,	04
	MOV	DX,	03C5H
	OUT	DX,	AL

	MOV	AX,	X
	ADD	AL,	3
	MOV	DX,	03C5H
	OUT	DX,	AL

	MOV	DI,	Y
	MOV	DX,	DI
	SHL	DI,	6
	SHL	DX,	4
	ADD	DI,	DX	{Y*80}

	MOV	AX,	X
	SHR	AX,	2       {X/4}
	ADD	DI,	AX
	ADD	DI,	WFrom

	MOV	ES,	SegA000
	MOV	AL,	ES:[DI]
End;

Procedure InitFlip; Assembler;
Asm
	MOV 	DX, 	03C5h
	MOV 	AL, 	0Fh
	OUT 	DX, 	AL
	MOV 	DX, 	03CEh
	MOV 	AX, 	08h
	OUT 	DX, 	AX
End;

Procedure DoneFlip; Assembler;
Asm
	MOV 	DX, 	03CFh
	MOV 	AX, 	0FFFFh
	OUT 	DX, 	AX
End;

Procedure FlipPage( Source, Destination: Word ); Assembler;
Asm
	PUSH	DS
	MOV	AX, SegA000
	MOV	ES, AX
	MOV	DS, AX
	MOV	DI, Destination
	MOV	SI, Source
	MOV	CX, WidthBytes*MaxY
	REP	MOVSB
	POP	DS
End;

Procedure Flip( PFrom,PX1,PY1,PX2,PY2,PTo,XT,YT : Word );
Var
  XC,YC : Word;
Begin
  Px1:= Px1 div 4;
  Px2:= Px2 div 4;
  xt := xt  div 4;

  For yc:= Py1 to Py2 do
    For xc:= Px1 to Px2 do
      Mem[SegA000: PTo   +WidthBytes*(yc-Py1+yt) +xc -Px1 +xt]:=
      Mem[SegA000: PFrom +WidthBytes*yc          +xc];
{
  For XC:=PX1 Div 4 To (PX2-4) Div 4 Do
    For YC:=PY1 To PY2 Do
      Mem[SegA000:(80*240*PTo)+80*(YC-PY1+YT) + XC-(PX1 Div 4)+(XT Div 4)]:=
	 Mem[SegA000:(240*80*PFrom)+80*YC+XC];}
End;

Procedure WriteFrom( Offset: Word );
Begin
  WFrom:= Offset
End;

Procedure WritePage( Page: Byte );
Begin
  WriteFrom( Page*MaxY*WidthBytes );
End;

Procedure ShowFrom( Offset: Word );
Begin
  SFrom:= Offset;
  PORT [$3D4]:= $0C;
  PORT [$3D5]:= SFrom shr 8;
  PORT [$3D4]:= $0D;
  PORT [$3D5]:= SFrom and $FF;
End;

Procedure ShowPage( Page: Byte);
Begin
  ShowFrom( Page*MaxY*WidthBytes );
End;

End.
