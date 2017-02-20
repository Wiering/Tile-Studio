unit ImpPovAni;

  { 
      Tile Studio

      Copyright (c) 2000-2017, Mike Wiering, Wiering Software

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:

      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
  }


  {$I SETTINGS.INC}

  { BMP bitmaps only! }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, ExtDlgs;

type
  TPovAni = class(TForm)
    OKButton: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    OpenButton: TButton;
    FirstFrame: TSpinEdit;
    L1: TLabel;
    L2: TLabel;
    LastFrame: TSpinEdit;
    CancelButton: TButton;
    Dimensions: TLabel;
    L3: TLabel;
    DivideFactor: TSpinEdit;
    L4: TLabel;
    XShift: TSpinEdit;
    L5: TLabel;
    L6: TLabel;
    YShift: TSpinEdit;
    procedure OKButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LastFrameChange(Sender: TObject);
    procedure FirstFrameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PovAni: TPovAni;
  CurTileW, CurTileH: Integer;
  SingleImage: Boolean;
  Done: Boolean;

implementation

uses Main, Tiles;

{$R *.DFM}

var
  Digits: Integer;
  X1, Y1, X2, Y2: Integer;
  ww, hh: Integer;
  FName: string;
  First, Last: Integer;
  XSize, YSize: Integer;
  iXShift, iYShift: Integer;

procedure TPovAni.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

function FileExists (Filename: string): Boolean;
  var
    SR: TSearchRec;
begin
  Result := FindFirst (Filename, faArchive, SR) = 0;
  FindClose (SR);
end;

function NumStr (N: LongInt; Len: Integer): string;
  var
    s: string;
    i: Integer;
begin
  Str (N: Len, s);
  for i := 1 to Length (s) do
    if s[i] = ' ' then
      s[i] := '0';
  NumStr := s;
end;

procedure GetRGB (RGB: Integer; var R: Integer; var G: Integer; var B: Integer);
begin
  R := RGB;
  G := RGB div $100;
  B := RGB div $10000;
  R := R and $FF;
  G := G and $FF;
  B := B and $FF;
end;

procedure TPovAni.OKButtonClick(Sender: TObject);
  var
    bmpANI: TBitmap;
    f: Integer;
    n: Integer;
    i, j, k: Integer;
    ii, jj, x, y: Integer;
    C, R, G, B, RR, GG, BB, Count, Trans: Integer;
    XSh, YSh: Integer;
begin
  f := DivideFactor.Value;
  XSh := XShift.Value;
  YSh := YShift.Value;

  with MainForm.TileTab[MainForm.Tab.TabIndex] do
  begin

    with tbr do
    begin
      Current := 0;
      if TileBitmap.Width >= CurTileW then
      begin
        TileBitmap.Width := CurTileW;
        TileCount := 1;
      end;
    end;

    for n := First to Last do
    begin
      tbr.Current := n;
      bmpANI := TBitmap.Create;
      bmpANI.PixelFormat := pf24bit;
      if SingleImage then
        bmpANI.LoadFromFile (FName + '.bmp')
      else
        bmpANI.LoadFromFile (FName + NumStr (n, digits) + '.bmp');
      Trans := bmpANI.Canvas.Pixels[0, 0];

      for j := 0 to CurTileH - 1 do
        for i := 0 to CurTileW - 1 do
        begin
          k := TRANS_COLOR;
          x := X1 + (i - iXShift) * f;
          y := Y1 + (j - iYShift) * f;
          if (i >= iXShift) and (j >= iYShift) and
             (i < iXShift + XSize) and
             (j < iYShift + YSize) then
          begin
            RR := 0;
            GG := 0;
            BB := 0;
            Count := 0;
            for jj := 0 to f - 1 do
              for ii := 0 to f - 1 do
              begin
                C := bmpANI.Canvas.Pixels[x + ii - f div 2 + XSh, y + jj - f div 2 + YSh];
                if C <> Trans then
                begin
                  GetRGB (C, R, G, B);
                  Inc (RR, R);
                  Inc (GG, G);
                  Inc (BB, B);
                  Inc (Count);
                end;
              end;
            if Count >= f * f div 2 then
//              if Count > 1 then
              k := RGB (RR div Count,
                        GG div Count,
                        BB div Count);
          end;

          with tbr.TileBitmap.Canvas do
            Pixels[tbr.Current * CurTileW + i, j] := k;
        end;

      bmpANI.Free;
      if n - First + 1 >= tbr.TileCount then
        CreateNewTile (tbr);
      MoveRight (tbr, TRUE);
    end;

  end;

  MainForm.Modified := TRUE;
  Done := TRUE;
  Close;
end;

procedure TPovAni.OpenButtonClick(Sender: TObject);
  var
    s: string;
    n, m: Integer;
    bmp: TBitmap;
    i, j, k: Integer;
begin
//  with OpenPictureDialog1 do
//    InitialDir := 'd:\povray\images';
  with OpenPictureDialog1 do
    if Execute then
    begin
      s := FileName;
      for m := 1 to Length (s) do
        s[m] := UpCase (s[m]);
      if Copy (s, Length (s) - 3, 4) <> '.BMP' then
        MessageDlg ('Only .BMP files are supported',
            mtError, [mbOk], 0)
      else
      begin
        Delete (s, Length (s) - 3, 4);
        m := Length (s);
        repeat
          Dec (m);
        until (m <= 1) or (not (s[m] in ['0'..'9']));
        digits := Length (s) - m;
        SingleImage := digits = 0;

        FirstFrame.Enabled := not SingleImage;
        LastFrame.Enabled := not SingleImage;
        DivideFactor.Enabled := TRUE;

        if SingleImage then
        begin
          First := -1;
          Last := -1;
          FName := s;
        end
        else
        begin
          n := StrToInt (Copy (s, m + 1, 255));
          s := Copy (s, 1, m);
          FName := s;
          m := n;
          while FileExists (s + NumStr (m, digits) + '.bmp') do
            Dec (m);
          Inc (m);
          First := m;
          FirstFrame.Value := m;
          m := n;
          while FileExists (s + NumStr (m, digits) + '.bmp') do
            Inc (m);
          Dec (m);
          Last := m;
        end;

        X1 := 10000000;
        Y1 := 10000000;
        X2 := -1;
        Y2 := -1;

        PovAni.Refresh;

        for m := First to Last do
        begin
          if not SingleImage then
          begin
            LastFrame.Value := m;
            LastFrame.Refresh;
          end;

          bmp := TBitmap.Create;
          bmp.PixelFormat := pf24bit;
          if m = -1 then
            bmp.LoadFromFile (s + '.bmp')
          else
            bmp.LoadFromFile (s + NumStr (m, digits) + '.bmp');

          with bmp do
          begin
            k := Canvas.Pixels[0, 0]; // assume transparent
            for j := 0 to Height - 1 do
              for i := 0 to Width - 1 do
              begin
                if Canvas.Pixels[i, j] <> k then
                begin
                  if i < X1 then X1 := i;
                  if j < Y1 then Y1 := j;
                  if i > X2 then X2 := i;
                  if j > Y2 then Y2 := j;
                end;
              end;
          end;
          bmp.Free;

          ww := x2 - x1 + 1;
          hh := y2 - y1 + 1;
          with Dimensions do
          begin
            Caption := 'Animation found at: ' +
                '(' + IntToStr (x1)+',' + IntToStr (y1) +
                '-' + IntToStr (x2) + ',' + IntToStr (y2) + ') ' +
                ' Size: ' + IntToStr (ww) + ', ' + IntToStr (hh);
            Left := 0;
            Width := PovAni.ClientWidth;
            Alignment := taCenter;
            Refresh;
          end;

          n := 0;
          repeat
            Inc (n);
          until (n * CurTileW >= ww) and (n * CurTileH >= hh);
          XSize := (ww + n - 1) div n;
          YSize := (hh + n - 1) div n;
          DivideFactor.Value := n;
          L4.Caption := 'Animation size: (' +
               IntToStr (XSize) + ',' +
               IntToStr (YSize) + ')';

          iXShift := (CurTileW - XSize) div 2;
          iYShift := (CurTileH - YSize) div 2;

          OKButton.Enabled := TRUE;
          OKButton.SetFocus;
        end;

      end;
    end;
end;

procedure TPovAni.FormShow(Sender: TObject);
begin
  FirstFrame.Enabled := FALSE;
  LastFrame.Enabled := FALSE;
  DivideFactor.Enabled := FALSE;
  OKButton.Enabled := FALSE;
  Done := FALSE;
end;

procedure TPovAni.LastFrameChange(Sender: TObject);
begin
  Last := LastFrame.Value
end;

procedure TPovAni.FirstFrameChange(Sender: TObject);
begin
  First := FirstFrame.Value
end;

end.
