
(* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   *)
(* º                                                        ºÛ  *)
(* º     Borland Pascal Version 7.0                         ºÛ  *)
(* º     Font Editor (Char size: 8 x 8)                     ºÛ  *)
(* º     dark - cloud programming                           ºÛ  *)
(* ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶Û  *)
(* º                                                        ºÛ  *)
(* º     Copyright (C) 1996 Diego Iastrubni                 ºÛ  *)
(* º                                                        ºÛ  *)
(* ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û  *)
(*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  *)

Program Font_Editor_8x8;

{$I-,X+,S-}

Uses Utils, XMode, Font8x8;

Const
  LX    = 220;    LY    = 080;
  FX    = 005;    FY    = 050;
  MSGX1 = 030;    MSGY1 = 040;
  MSGX2 = 280;    MSGY2 = 165;
  STRX  = 070;    STRY  = 095;
  SFX   = 160;    SFY   = 010;
  LOCX  = 160;    LOCY  = 020;
  DMX   = 160;    DMY   = 030;
  TSTX  = 170;    TSTY  = 060;
  ATVX  = 160;    ATVY  = 090;
  TXTX1 = 050;    TXTY1 = 030;
  TXTX2 = 270;    TXTY2 = 143;
  PLX   = 190;    PLY   = 060;

  BackColor            = 25;
  Boxcolor             = 26;
  CursorColor          = 10;

  Colored = 1;
  Blacked = 25;

  AsciiBack       = 7;
  TextColor       = CursorColor;
  BackGroundColor = BackColor;
  MsgBack         = 24;

Const
  FontSize   = SizeOf(TFont);
  LetterSize = SizeOf(TLetter);

(* Utilities *)

Procedure InitScreen; Forward;

Procedure IncByRange( Var n: Byte; Min,Max: Byte ); Assembler;
Asm
   LES          BX,     n
   MOV          AL,     ES:[BX]
   INC          AL
   CMP          AL,     Max
   JNG          @Continue
   MOV          AL,     Min
@Continue:
   MOV          ES:[BX],AL
End;

Procedure DecByRange( Var n: Byte; Min,Max: Byte ); Assembler;
Asm
   LES          BX,     n
   MOV          AL,     ES:[BX]
   DEC          AL
   CMP          AL,     Min
   JNL          @Continue
   MOV          AL,     Max
@Continue:
   MOV          ES:[BX],AL
End;

Procedure Xor_Bit( Var Number: Byte; N: Byte );
Begin
  Number:= Number xor (1 shl n);
End;

Procedure SetNot( Var Letter: TLetter );
Var
  n: Byte;
Begin
  For n:= 1 to 8 do
    Letter[n]:= not Letter[n];
End;

Procedure Write_Char( x,y: Word; ALetter: TLetter);
Var
  xx,yy: Byte;
Begin
  For yy:=1 to 8 do             { The Array }
    For xx:=1 to 8 do           { Bits      }
      If GetBit( ALetter[yy],xx-1 )
        Then PutPixel( x+(8-xx)-1, y+yy-1, Color )
        Else PutPixel( x+(8-xx)-1, y+yy-1, Back  )
End;

Procedure Write_Str( x,y: Word; Text: String; Font: TFont );
Var
  n,d: Byte;
Begin
  d:=0;
  For n:= 1 to Length( Text ) do
    Begin
      Write_Char( x+d, y, Font[Text[n]] );
      Inc(d,16)
    End;
End;

Procedure Write_The_Letter( ALetter: TLetter );
Var
  x,y: Byte;
Begin
  For  y:=1 to 8 do             { The Array }
    For  x:=1 to 8 do           { Bits      }
      If GetBit( ALetter[y],x-1 )
        Then Box( LX+(8-x)*10+1,LY+(y-1)*10+1,
          LX+(8-x)*10+9 ,LY+(y-1)*10+9, Colored )
        Else Box( LX+(8-x)*10+1,LY+(y-1)*10+1,
          LX+(8-x)*10+9 ,LY+(y-1)*10+9, Blacked )
End;

(* Screen *)
Procedure DrawBox( CurrX,CurrY: Byte );
Var
  xc,yc : Byte;
Begin
  For xc:=0 To 8 Do
    For yc:=1 To 9 Do
      PutPixel(LX+(8-xc)*10, LY+(yc-1)*10, BoxColor );

  Dec(CurrX);
  Dec(CurrY);
  PutPixel(CurrX*10+LX   , CurrY*10+LY   , CursorColor);
  PutPixel(CurrX*10+LX+10, CurrY*10+LY   , CursorColor);
  PutPixel(CurrX*10+LX   , CurrY*10+LY+10, CursorColor);
  PutPixel(CurrX*10+LX+10, CurrY*10+LY+10, CursorColor);
End;

Procedure PrintFont( Var Font: TFont; CharStart: Byte );
Var
  x, y: Byte;
  S: String[3];
Begin
  Str( CharStart:3,S );
  WriteStr( SFX, SFY, 'ASCII:'+S );
  Back:= AsciiBack;

  For y:= 0 to 15 do
    For x:= 0 to 15 do
      Write_Char( FX+(x*9)+1, FY+(y*9)+2, Font[ Char(y*16+x+CharStart) ] );

  Back:= BackColor;
End;

Procedure PrintLocation( x,y: Byte );
Var
  S1,S2: String[3];
Begin
  Str(X,S1);
  Str(Y:2,S2);
  WriteStr( LOCX, LOCY, 'X,Y: ('+S1+')('+S2+')' );
End;

Procedure SetActive( Var Active: Char; NewActive: Byte );
Var
  S: String[3];
Begin
  Active:= Char(NewActive);
  Str( NewActive:3, S );
  WriteStr( ATVX, ATVY, S );
End;

(* Input *)
Procedure LoadDosFont( Const Name: String; Var Font: TFont );
Var
  F: File;
Begin
  Assign( F, Name );
  Reset( F, 1 );
  BlockRead( F, Font, FontSize );
  Close( F );
End;

Procedure DoHelp;
Var
  SaveColor,
  SaveBack: Byte;
Begin
  SaveColor:= Color;
  SaveBack:= Back;
  Color:= TextColor;
  Back:= MsgBack;
  InterNal:= MsgBack;

  Box3D( MSGX1, MSGY1, MSGX2, MSGY2, False );
  WriteStr( MSGX1+25, MSGY1+15, 'HELP' );

  WriteStr( MSGX1+7, MSGY1+090, 'Ctrl+Enter : White');
  WriteStr( MSGX1+7, MSGY1+100, 'Alt +Space : Draw Mode');
  WriteStr( MSGX1+7, MSGY1+110, 'Alt-X      : Quit');

  WriteStr( MSGX1+7,   MSGY1+75, 'Enter Black');
  WriteStr( MSGX1+105, MSGY1+75, 'Space Xor  ');

  WriteStr( MSGX1+100, MSGY1+07, 'F2 Save' );
  WriteStr( MSGX1+100, MSGY1+17, 'F3 Open' );
  WriteStr( MSGX1+100, MSGY1+27, 'F4 Goto Char');

  WriteStr( MSGX1+10,  MSGY1+40, 'F5 Test Font');
  WriteStr( MSGX1+10,  MSGY1+50, 'F6 Copy char');
  WriteStr( MSGX1+10,  MSGY1+60, 'F7 Paste char');

  Ascii;

  Color:= SaveColor;
  Back:= SaveBack;
  Internal:= 23;
End;


Procedure LoadTheFont( Var Font: TFont );
Var
  SaveColor,
  SaveBack: Byte;
  FName: String;
  F: File;
Begin
  SaveColor:= Color;
  SaveBack:= Back;
  Color:= TextColor;
  Back:= MsgBack;
  FName:= '';
  Internal:= MsgBack;

  Box3D( MSGX1, MSGY1, MSGX2, MSGY2, False );
  WriteStr( MSGX1+75, MSGY1+10, 'OPEN' );
  WriteStr( STRX, STRY, 'ENTER THE FILE NAME: ' );
  ReadStr( STRX, STRY+20, FName, 20 );

  If FName<>'' Then Begin
    Assign( F, FName );
    Reset( F, 1 );
    BlockRead( F, Font, FontSize );
    Close( F );

    If IOResult<>0 Then Begin
      WriteStr( MSGX1+10, MSGY2-20, 'NOT FOUND.PRESS ANY KEY' );
      Ascii;
    End;
  End;

  Color:= SaveColor;
  Back:= SaveBack;
  Internal:= 23;
End;

Procedure SaveTheFont( Var Font: TFont );
Var
  SaveColor,
  SaveBack: Byte;
  FNAme: String;
  F: File;
Begin
  SaveColor:= Color;
  SaveBack:= Back;
  Color:= TextColor;
  Back:= MsgBack;
  FName:= '';
  Internal:= MsgBack;

  Box3D( MSGX1, MSGY1, MSGX2, MSGY2, False );
  WriteStr( MSGX1+75, MSGY1+10, 'SAVE' );
  WriteStr( STRX, STRY, 'ENTER THE FILE NAME: ' );
  ReadStr( STRX, STRY+20, FName, 20 );

  If FName<>'' Then Begin
    Assign( F, FName );
    ReWrite( F, 1 );
    BlockWrite( F, Font, FontSize );
    Close( F );

    If IOResult<>0 Then Begin
      WriteStr( MSGX1+5, MSGY2-20, 'NOT SAVED. PRESS ANY KEY' );
      Ascii;
    End;

  End;

  Color:= SaveColor;
  Back:= SaveBack;
  Internal:= 23;
End;

Procedure DoGotoNum( Var Active: Char );
Var
  SaveColor,
  SaveBack: Byte;
  Chr: String;
  N,I: Integer;
  F: File;
Begin
  SaveColor:= Color;
  SaveBack:= Back;
  Color:= TextColor;
  Back:= MsgBack;
  Chr:= '';
  Internal:= MsgBack;
  I:= 0;
  N:= 0;

  Box3D( MSGX1, MSGY1, MSGX2, MSGY2, False );
  WriteStr( MSGX1+65, MSGY1+10, 'GOTO CHAR' );
  WriteStr( STRX, STRY, 'ENTER THE NEW CHAR: ' );
  ReadStr( STRX, STRY+20, Chr, 12 );
  If Chr<>'' Then
    Begin
      Val( Chr, N, I);
      If (I=0) and (N<256) and (N>-1) Then SetActive( Active, N );
    End;

  Color:= SaveColor;
  Back:= SaveBack;
  Internal:= 23;
End;

Procedure TestFont( Var Font: TFont );
var
  x,y: Byte;
  i,j,k: Byte;
  c: Char;
Begin
  x:= 0;
  y:= 0;

  i:= Internal;
  j:= Color;
  k:= Back;

  Color:= 7;
  Back:= 0;

  Internal:= Black;
  Box3D( TXTX1, TXTY1, TXTX2, TXTY2, False );

  Repeat
    c:= Ascii;
    If (C<>#0) and (C<>#8) and (C<>#13) and (C<>#10)
       Then Write_Char( (x*8)+TXTX1+2, (y*8)+TXTY1+2, Font[c] );

    Case c of
      #0: Case Port[$60] of
            71: x:= 0;
            79: x:= 26;
            80: IncByRange( Y, 0, 13 );
            72: DecByRange( Y, 0, 13 );
            77: IncByRange( X, 0, 27 );
            75: DecByRange( X, 0, 26 );
            59..67: ;
            68: Box3D( TXTX1, TXTY1, TXTX2, TXTY2, False );
            Else Write_Char( (x*8)+TXTX1+2, (y*8)+TXTY1+2, Font[c] );
          End;
      #8: Begin
            DecByRange( x, 0, 1 );
            Write_Char( (x*8)+TXTX1+2, (y*8)+TXTY1+2, Font[#32] );
          End;
      #13: IncByRange( y, 0, 13 );
      #10: x:= 0;
      Else Begin
             Inc( x );
             If x=27 Then Begin x:= 0; IncByRange( Y, 0, 13 ); End;
           End;
    End;
  Until c=#27;

  Internal:= i;
  Color:= j;
  Back:= k;


  i:= Back;
  Back:= Internal;
  Box3D( TXTX1, TXTY1+120, TXTX2, TXTY2+50, False );
  WriteStr( TXTX1+25, TXTY1+135, 'PRESS ANY KEY...' );
  Back:= i;
  Ascii;
End;

(* Main *)
Procedure InitFont;              { Graphic font }
Var
  P: Pointer;
Begin
  New( Font );
  SetBiosFont( Font^ );
End;

Procedure InitScreen;
Begin
  Utils.PutPixel:= XMode.PutPixel;
  SetXMode;
  GCLS( BackColor );
  Box3D( TSTX-10, TSTY-9, PLX+15      , PLY+15      , True );
  Box3D( FX-4   , FY-2  , FX+(10*14)+6, FY+(13*11)+4, False );
  Box3D( LX-2   , LY-4  , LX+8*10+2   , LY+16*5+4   , False );
  Box3D( TSTX-5 , TSTY-4, TSTX+10     , TSTY+10     , False );
  Box3D( PLX-5  , PLY-4 , PLX+10      , PLY+10      , False );

  Color := Colored;
  Back  := BackColor;
End;

Procedure RunProgram;
Var
  CurrX, CurrY,
  StartChar: Byte;
  Active: Char;
  TheFont: TFont;
  DrawMode, MustQuit: Boolean;
  KBCode: TKBCode;
  PasteChar: TLetter;

Procedure HandleFunctions(ScanCode: Byte);
Begin
  Case ScanCode Of
    45 : MustQuit:= True;
    59 : Begin
           InitFlip;
           FlipPage( Page0, Page2 );
           DoneFlip;
           DoHelp;
           InitFlip;
           FlipPage( Page2, Page0 );
           DoneFlip;
         End;
    60 : Begin
           InitFlip;
           FlipPage( Page0, Page2 );
           DoneFlip;
           SaveTheFont( TheFont );
           InitFlip;
           FlipPage( Page2, Page0 );
           DoneFlip;
           PrintFont( TheFont, StartChar );
         End;
    61 : Begin
           InitFlip;
           FlipPage( Page0, Page2 );
           DoneFlip;
           LoadTheFont( TheFont );
           InitFlip;
           FlipPage( Page2, Page0 );
           DoneFlip;
           PrintFont( TheFont, StartChar );
         End;
    62 : Begin
           InitFlip;
           FlipPage( Page0, Page2 );
           DoneFlip;
           DoGotoNum( Active );
           InitFlip;
           FlipPage( Page2, Page0 );
           DoneFlip;
           SetActive( Active, Byte(Active) );
         End;
    63 : Begin
           InitFlip;
           FlipPage( Page0, Page2 );
           DoneFlip;
           TestFont( TheFont );
           InitFlip;
           FlipPage( Page2, Page0 );
           DoneFlip;
           SetActive( Active, Byte(Active) );
         End;
    64 : Begin
           PasteChar:= TheFont[Active];
           Back:= Internal;
           Write_Char( PLX, PLY, PasteChar);
           Back:= BackColor;
         End;
    65 : TheFont[Active]:= PasteChar;

 81,73 : Begin
           If ScanCode=73 Then Dec( StartChar,16 );
           If ScanCode=81 Then Inc( StartChar,16 );
           If ShiftState and kbCtrl<>0 Then
             Case ScanCode of
               73: StartChar:= 0;
               81: StartChar:= 128;
             End;
           PrintFont( TheFont, StartChar );
         End;
    80 : IncByRange( CurrY, 1, 8 );
    72 : DecByRange( CurrY, 1, 8 );

    77 : IncByRange( CurrX, 1, 8 );
    75 : DecByRange( CurrX, 1, 8 );

    82 : SetNot( TheFont[Active] );
    83 : FillChar( TheFont[Active], LetterSize, 0 );
    71 : SetActive(Active, 0);
    79 : SetActive(Active, 128);
  End;
End;

Procedure ChangeDrawMode;
Begin
  DrawMode:= Not DrawMode;

  If DrawMode
    Then Color:= Blue
    Else Color:= LightBlue;

  WriteStr( DMX, DMY, 'Draw Mode');
  Color:= Colored;
End;

Begin
  CurrX:= 1;
  CurrY:= 1;
  StartChar:= 0;
  SetActive( Active,Byte('A') );
  FillChar( PasteChar, SizeOf(TLetter), 0 );
  MustQuit:= False;
  DrawMode:= False;

  If (ParamStr(1)<>'') and FileExist(ParamStr(1))
    Then LoadDosFont( ParamStr(1), TheFont )
    Else Move( Font8x8.Font^, TheFont, SizeOf( TFont ) );

  PrintFont (TheFont ,StartChar);
  Back:= BackColor;

  Repeat
    If DrawMode Then SetBit( TheFont[Active][CurrY],8-CurrX, True );
    Write_The_Letter( TheFont[Active] );
    DrawBox(CurrX, CurrY);
    PrintLocation(CurrX, CurrY);
    Back:= Internal;
    Write_Char( TSTX, TSTY, TheFont[Active]);
    Back:= BackColor;

    Word(KBCode):= GetKBCode;
    Case KBCode.Ascii of
      #00 : HandleFunctions(KBCode.ScanCode);
      #32 : If ShiftState and kbAlt=0
               Then Xor_Bit( TheFont[Active][CurrY],8-CurrX )
               Else ChangeDrawMode;
      #33..#126 : If not (KBCode.ScanCode in [74,78])
                    Then SetActive( Active, Byte(KBCode.Ascii) );
      #13 : SetBit( TheFont[Active][CurrY],8-CurrX, True );
      #10 : SetBit( TheFont[Active][CurrY],8-CurrX, False );
    End;
    If KBCode.ScanCode=74 Then SetActive(Active, Byte(Active)-1);
    If KBCode.ScanCode=78 Then SetActive(Active, Byte(Active)+1);
  Until MustQuit;
End;

Procedure  DoneScreen;
Begin
  SetText;
End;

Procedure DoneFont;
Begin
  Dispose(Font);
End;


Begin
  InitScreen;
  InitFont;
  RunProgram;
  DoneScreen;
  DoneFont;
End.

    dark-cloud : http://www.geocities.com/SiliconValley/Vista/1959
                 dark-cloud@geocities.com
