unit SZPCX;

/////////////////////////////
// Version 1.0.2
/////////////////////////////

{

 The contents of this file are subject to the Mozilla Public License
 Version 1.1 (the "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
 specific language governing rights and limitations under the License.

 The original code is SZPCX.pas, released 19. July, 2004.

 The initial developer of the original code is
 Sasa Zeman (public@szutils.net, www.szutils.net)

 Copyright(C) 2004-2006 Sasa Zeman. All Rights Reserved.
}

{--------------------------------------------------------------------

- Simple and fast reader of PCX format.
- Capable to read B/W, 16, 256 and 16M colors
- Register as a common graphical format in Delphi (TPicture support)

TODO:
  - Encoding to PCX format.
  - Full Assign support


Revision History:
----------------------------------

Version 1.0.2, 2006-12-06
  - Memory leak fixed
                
Version 1.0.1, 2006-12-01
  - Some small class rearanging and source publishing

Version 1.0.0, 2004-07-19
  - Initial version

----------------------------------

  Author   : Sasa Zeman
  E-mail   : public@szutils.net or sasaz72@mail.ru
  Web site : www.szutils.net
}



interface

uses SysUtils,Windows,Classes,Graphics;

type

  TSZPCXPixelFormat=(SZPCXpfUnknown, SZPCXpf1bit, SZPCXpf4bit, SZPCXpf8bit, SZPCXpf24bit);

  TRGBColor = packed record
    R, G, B: byte;
  end;

  TArr8RGB = array[1..8] of TRGBColor;

  VGAPalette = array[0..255] of TRGBColor;

  PRGBArray=^TRGBArray;
  TRGBArray= array[0..0] of TRGBColor;

  TSZPCXHeader = Record
    Manufacturer : byte;   {Const 10 = ZSoft}
    Version      : byte;   {0 = 2.5 PC Paintbrush}
                           {2 = 2.8 PC Paintbrush with palette info}
                           {3 = 2.8 PC Paintbrush without palette info}
                           {4 = PC Paintbrush for Windows}
                           {5 = 3.0 PC Paintbrush, Paintbrush Plus,
                                Publisher's Paintbrush}
    Encode       : byte;   {1 = Run-Length compression}
    BitsPerPixel : byte;   {Bits per pixel
                            1 - 16 color
                            2 -
                            4,8 - 256 and 16M}
    Window       : record
                      Xmin,Ymin,
                      Xmax,Ymax: word;
                   end;    {Picture dimension}
    HDPI         : word;   {Horizontal resolution in DPI}
    VDPI         : word;   {Vertical   resolution in DPI}
    ColorMap     : array[0..15] of TRGBColor;
                           {Color palette - only on 16 color map}
                           {768 last bytes of file for color palette
                            above 16 color - 1 byte before must be 12}
    Reserved     : byte;   {Reserved = 0}
    NPlanes      : byte;   {Number of bits for planes
                            1 - 256 color
                            3 - 16M color
                            4 - 16  color }
    BytesPerLine : word;   {Bytes per line -   mod 2 = 0}
    PaletteInfo  : word;   {1 - Standard color/BW palette}
                           {2 - Grayscale}
    HScreenSize  : word;
    VScreenSize  : word;
    Filler       : array [0..53] of byte;
  End;

  TSZPCX = class(TBitmap)
  private
    Header  : TSZPCXHeader;
    VGApal  : VGAPalette;

    RawData : TMemoryStream;
    OutData : Pointer;

    pRawData, pOutData: PByte;
    pR,pG,pB: PByte;

    PCXPixelFormat: TSZPCXPixelFormat;

    procedure DecodeBytes(pOutData: pByte; TotalBytes : integer);
    procedure ReadLine(LineNum,TotalBytes: integer);

    function GetPixelFormat: TSZPCXPixelFormat;

  public
    FBitmap: TBitmap;
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromFile( Const Filename: String); override;
    procedure LoadFromStream(Stream: TStream); override;

    procedure ReadAll;

  end;

  TSZPCXImage=class(TBitmap)
  Public

    constructor Create; override;
    destructor Destroy; override;

    procedure LoadFromStream(Stream: TStream); override;
  end;

implementation

const
   Bin: array[0..7] of byte =
        (1,2,4,8,16,32,64,128);

constructor TSZPCX.Create;
begin
  FBitmap:=TBitmap.Create;
  RawData:=TMemoryStream.Create;
end;

destructor TSZPCX.Destroy;
begin
  RawData.Free;
  FBitmap.Free;

  inherited destroy;
end;

function TSZPCX.GetPixelFormat: TSZPCXPixelFormat;
begin

  result := SZPCXpfUnknown;

  case Header.BitsPerPixel of
     8 : begin
          if (Header.PaletteInfo  = 1) and
             (Header.Nplanes      = 3)
          then
            // True color
            result := SZPCXpf24bit
          else
            // 256 color
            result := SZPCXpf8bit;
         end;

     4: begin
          // 16 color
          result := SZPCXpf4bit;
        end;

     1: begin
          // BW color
          result := SZPCXpf1bit;
        end;
   end;
end;


procedure TSZPCX.DecodeBytes(pOutData: pByte; TotalBytes : integer);
var
  b: byte;
  bytes: integer;
  a: PByte;
begin
  bytes:=0;

  while bytes<TotalBytes do
  begin

    a:= pRawData; inc(pRawData);

    if (a^ and $C0)=$C0 then
    begin
      b := a^ and $3F;
      a := pRawData; inc(pRawData);
    end else
    b:=1;

    if b>1 then
    begin
      FillChar(pOutData^,b,a^);
      inc(pOutData,b);
      inc(bytes,b);
    end else
    repeat
      pOutData^:=a^; inc(pOutData);
      inc(bytes);
      dec(b);
    until b=0;
  end;
end;

procedure TSZPCX.LoadFromFile(Const Filename: String);
begin
  RawData.LoadFromFile(Filename);
  pRawData:=RawData.Memory;

  ReadAll;
end;

procedure TSZPCX.LoadFromStream(Stream: TStream);
begin
  RawData.LoadFromStream(Stream);
  ReadAll;
end;

procedure TSZPCX.ReadLine(LineNum, TotalBytes: integer);
var
  bytes: integer;

  P:^TRGBTriple;
  P1Byte: PByte;
begin

  pOutData:=OutData;
  DecodeBytes(pOutData,TotalBytes);
  pOutData:=OutData;

  P1Byte := FBitmap.ScanLine[LineNum];

  case PCXPixelFormat of
    SZPCXpf1bit,
    SZPCXpf4bit,
    SZPCXpf8bit: CopyMemory(p1Byte,pOutData,Header.BytesPerLine);

    SZPCXpf24bit:
    begin

      pR:=pOutData;
      pG:=pR; inc(pG,Header.BytesPerLine);
      pB:=pG; inc(pB,Header.BytesPerLine);

      P:=@(P1Byte^);
      
      for bytes:=1 to Header.BytesPerLine do
      begin
        p.rgbtRed   := pR^; inc(pR);
        p.rgbtGreen := pG^; inc(pG);
        p.rgbtBlue  := pB^; inc(pB);

        inc(p)
      end;
    end
  end
end;

procedure TSZPCX.ReadAll;
var
  i,y: integer;
  n: byte;
  Size: record
    X,Y:word;
  end;

  TotalBytes: integer;

  LogPalette: TMaxLogPalette;
begin
  RawData.Seek(0,soFromBeginning);
  RawData.Read(header,sizeof(TSZPCXHeader));

  with Header do
  begin
    case PaletteInfo of
      0,1: begin
           if (Version>=5)then
           begin
             //RawData.Seek(RawData.Size-769,soFromBeginning);
             RawData.Seek(-769,soFromEnd);
             RawData.Read(n,1);

             if n=12
                then RawData.read(VGApal,768)
                else Move(Header.ColorMap,VGAPal,48)

           end else
                 Move(Header.ColorMap,VGAPal,48);
         end;
    end;

    RawData.seek(128,soFromBeginning);

    with Window do
    begin
       Size.X := XMax - XMin + 1;
       Size.Y := YMax - YMin + 1;
    end;

    PCXPixelFormat:=GetPixelFormat;

    with FBitmap do
    begin
      Assign(nil);

      case PCXPixelFormat of
        SZPCXpf1bit:  PixelFormat := pf1bit;
        SZPCXpf4bit:  PixelFormat := pf4bit;
        SZPCXpf8bit:  PixelFormat := pf8bit;
        SZPCXpf24bit: PixelFormat := pf24bit;
      else
        PixelFormat := pf24bit;
      end;

      Width :=Size.X;
      Height:=Size.Y;     

      // Create palette
      if PCXPixelFormat in [SZPCXpf4bit,SZPCXpf8bit] then
      begin
        FillChar(LogPalette, SizeOf(LogPalette), 0);
        LogPalette.palVersion := $300;

        if PCXPixelFormat= SZPCXpf8bit then
          LogPalette.palNumEntries := 256;

        if PCXPixelFormat= SZPCXpf4bit then
          LogPalette.palNumEntries := 48;

        for i:=0 to LogPalette.palNumEntries-1 do
        begin
          LogPalette.palPalEntry[i].peRed   := VGAPal[i].R;
          LogPalette.palPalEntry[i].peGreen := VGAPal[i].G;
          LogPalette.palPalEntry[i].peBlue  := VGAPal[i].B;
        end;

        FBitmap.Palette := CreatePalette(PLogPalette(@LogPalette)^);
      end;
    end;

    TotalBytes := NPlanes * BytesPerLine;

    //point to the first dot data

    pRawData:=RawData.Memory;
    inc(pRawData,128);

    if PCXPixelFormat = SZPCXpf24bit then
    begin
      pR := pRawData;
      pG := pR; inc(pG,Header.BytesPerLine);
      pB := pG; inc(pB,Header.BytesPerLine);
    end;

    GetMem(OutData, TotalBytes);

    for y:=0 to Size.Y-1 do
      ReadLine(y,TotalBytes);

    FreeMem(OutData);
  end;
end;

constructor TSZPCXImage.Create;
begin
  inherited Create;
end;

destructor TSZPCXImage.Destroy;
begin
  inherited Destroy
end;

procedure TSZPCXImage.LoadFromStream(Stream: TStream);
var
  PCX: TSZPCX;
begin
  PCX:=TSZPCX.Create;
  try
    PCX.RawData.LoadFromStream(Stream);
    PCX.ReadAll;
    Assign(PCX.FBitmap);
  except end;

  PCX.Free;
end;

initialization
  TPicture.RegisterFileFormat('pcx', 'PCX Image File (SZ)', TSZPCXImage);
finalization
  TPicture.UnregisterGraphicClass(TSZPCXImage);
end.
