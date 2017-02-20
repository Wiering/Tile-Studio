unit Import;

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

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Spin, ComCtrls;

type
  TImportTiles = class(TForm)
    ScrollBox: TScrollBox;
    PreviewPicture: TImage;
    TileWidth: TSpinEdit;
    L1: TLabel;
    TileHeight: TSpinEdit;
    L2: TLabel;
    HorzSpace: TSpinEdit;
    VertSpace: TSpinEdit;
    ClipLeft: TSpinEdit;
    ClipTop: TSpinEdit;
    L3: TLabel;
    L4: TLabel;
    L5: TLabel;
    L6: TLabel;
    L7: TLabel;
    PositionLabel: TLabel;
    SmallScrollBox: TScrollBox;
    PaintBox: TPaintBox;
    ImportButton: TButton;
    CancelButton: TButton;
    Identifier: TEdit;
    L0: TLabel;
    AutoDetectButton: TButton;
    Trans: TPanel;
    Mult: TImage;
    procedure FormShow(Sender: TObject);
    procedure PreviewPictureMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PreviewPictureMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure PreviewPictureMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure UpdatePreview(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
    procedure IdentifierKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AutoDetectButtonClick(Sender: TObject);
    procedure TransMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    Selecting: Boolean;
    BmpW, BmpH: Integer;
    CurX, CurY: Integer;
    DefaultName: string;
    procedure ShowPos (X, Y: Integer);
  public
    { Public declarations }
    TransX, TransY: Integer;
    Result: Boolean;
    TransList: array of Integer;
  end;

var
  ImportTiles: TImportTiles;

implementation

uses Main, Tiles {$IFDEF PNGSUPPORT} {$ENDIF};

{$R *.DFM}

procedure TImportTiles.FormShow(Sender: TObject);
  var
    Filename: string;
    id: string;
  {$IFDEF PNGSUPPORT}
    png: TBitmap;
  {$ENDIF}
begin
  TransX := -1;
  TransY := -1;
  Filename := MainForm.OpenPictureDialog.Filename;
  id := Filename;
  while (id <> '') and (Pos ('\', id) > 0) do
    Delete (id, 1, 1);
  if Pos ('.', id) > 0 then
    Delete (id, Pos ('.', id), 255);
  if MainForm.TCNameOK (id, FALSE) then
    Identifier.Text := id
  else
    Identifier.Text := MainForm.NewTCName;
  DefaultName := Identifier.Text;

  with PreviewPicture do
  begin
  {$IFDEF PNGSUPPORT}
    if UpperCase (ExtractFileExt (Filename)) = '.PNG' then
    begin
      png := TBitmap.Create;
      ReadBitmapFromPngFile (Filename, png);
      Picture.Bitmap.Assign (png);
      png.Free;
    end
    else
  {$ENDIF}
      Picture.LoadFromFile (Filename);
    Picture.Bitmap.PixelFormat := pf24bit;
    ImportTiles.Caption := 'Importing tiles from ' + Filename;
    BmpW := Picture.Bitmap.Width;
    BmpH := Picture.Bitmap.Height;
    Width := BmpW;
    Height := BmpH;
    ShowPos (0, 0);
    if (UpperCase (ExtractFileExt (Filename)) = '.PNG') and
       (not Transparent) then
    begin
      Trans.Color := clBtnFace;
      SetLength (TransList, 0);
      Trans.Caption := 'None';
    end
    else
    begin
      Trans.Caption := '';
      if Transparent then
        Trans.Color := Picture.Bitmap.TransparentColor;
      Trans.Color := Canvas.Pixels[Width - 1, Height - 1];
      SetLength (TransList, 1);
      TransList[0] := Trans.Color;
    end;
    Mult.Visible := FALSE;
  end;

  UpdatePreview(Sender);
end;

procedure TImportTiles.PreviewPictureMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    Selecting := TRUE;
    PreviewPictureMouseMove(Sender, Shift, X, Y);
  end;
end;

procedure TImportTiles.PreviewPictureMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
  var
    i, C: Integer;
    Found: Boolean;
begin
  ShowPos (X, Y);
  if Selecting then
  begin
    if ssShift in Shift then
    begin
      C := PreviewPicture.Canvas.Pixels[X, Y];
      Found := FALSE;
      for i := 0 to Length (TransList) - 1 do
        if TransList[i] = C then
          Found := TRUE;
      if not Found then
      begin
        SetLength (TransList, Length (TransList) + 1);
        TransList[Length (TransList) - 1] := C;
        with Mult do
        begin
          Picture.Bitmap.Width := Length (TransList);
          Picture.Bitmap.Height := 1;
          for i := 0 to Length (TransList) - 1 do
            Canvas.Pixels[i, 0] := TransList[i];
          Visible := TRUE;
        end;
      end;
    end
    else
    begin
      TransX := X;
      TransY := Y;
      Trans.Caption := '';
      Trans.Color := PreviewPicture.Canvas.Pixels[X, Y];
      SetLength (TransList, 1);
      TransList[0] := Trans.Color;
      Mult.Visible := FALSE;
    end;
  end;
  CurX := X;
  CurY := Y;
  PaintBox.Repaint;
end;

procedure TImportTiles.PreviewPictureMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    Selecting := FALSE;
end;

procedure TImportTiles.ShowPos (X, Y: Integer);
begin
  with PositionLabel do
  begin
    Caption :=
      'Size: (' + IntToStr (BmpW) + ', ' + IntToStr (BmpH) + '), ' +
      'Position: (' + IntToStr (X) + ', ' + IntToStr (Y) + ')';
    Width := ScrollBox.Width;
    Alignment := taCenter;
  end;
end;

procedure TImportTiles.PaintBoxPaint(Sender: TObject);
  var
    Src, Dst: TRect;
    W, H: Integer;
    X, Y: Integer;
    CL, CT: Integer;
begin
  if (BmpW > 0) and (BmpH > 0) then
  begin
    with PaintBox do
    begin
      try
        W := Width + HorzSpace.Value;
      except
        W := Width;
      end;
      try
        H := Height + VertSpace.Value;
      except
        H := Height;
      end;
      if (W > 0) and (H > 0) then
      begin
        try
          CL := ClipLeft.Value;
        except
          CL := 0;
        end;
        try
          CT := ClipTop.Value;
        except
          CT := 0;
        end;
        X := (CurX - CL) div W;
        Y := (CurY - CT) div H;
        if X < 0 then
          X := 0;
        if Y < 0 then
          Y := 0;
        Left := SmallScrollBox.ClientWidth div 2 - Width div 2;
        Top := SmallScrollBox.ClientHeight div 2 - Height div 2;
        Dst := Rect (0, 0, Width, Height);
        Src.Left := CL + X * W;
        Src.Top := CT + Y * H;
        Src.Right := Src.Left + Width;
        Src.Bottom := Src.Top + Height;
        Canvas.Copyrect (Dst, PreviewPicture.Picture.Bitmap.Canvas, Src);
      end;
    end;
  end;
end;

procedure TImportTiles.UpdatePreview(Sender: TObject);
  var
    W, H: Integer;
begin
  try
    W := TileWidth.Value
  except
    W := 0;
  end;
  try
    H := TileHeight.Value
  except
    H := 0;
  end;
  if W > 0 then
    PaintBox.Width := W;
  if H > 0 then
    PaintBox.Height := H;
  PaintBox.Repaint;
end;

procedure TImportTiles.CancelButtonClick(Sender: TObject);
begin
  Result := FALSE;
  Close;
end;

procedure TImportTiles.ImportButtonClick(Sender: TObject);
begin
  if MainForm.TCNameOK (Identifier.Text, FALSE) then
  begin
    Result := TRUE;
    Close;
  end
  else
  begin
    MainForm.IdError (Identifier.Text);
    Identifier.Text := DefaultName;
    Identifier.SetFocus;
  end;
end;



procedure TImportTiles.IdentifierKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    ImportButtonClick (Sender);
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

procedure TImportTiles.AutoDetectButtonClick(Sender: TObject);

  const
    MOST = 80;

  function RowPerc (y, C: Integer): Integer;
    var
      x, n: Integer;
  begin
    n := 0;
    for x := 0 to BmpW - 1 do
    begin
      if PreviewPicture.Canvas.Pixels[x, y] = C then
        Inc (N);
    end;
    RowPerc := N * 100 div BmpW;
  end;

  function ColPerc (x, C: Integer): Integer;
    var
      y, n: Integer;
  begin
    n := 0;
    for y := 0 to BmpH - 1 do
    begin
      if PreviewPicture.Canvas.Pixels[x, y] = C then
        Inc (N);
    end;
    ColPerc := N * 100 div BmpH;
  end;

  function GuessValue (x1, y1, x2, y2: Integer): Integer;
    var
      V: Integer;
      a, b: Integer;
      t: Integer;
  begin
    V := 0;
    t := Trans.Color;
    a := PreviewPicture.Canvas.Pixels[x1, y1];
    b := PreviewPicture.Canvas.Pixels[x2, y2];
    Inc (V, Byte (a <> b) * 1);
    Inc (V, Byte ((a = t) or (b = t)) * 5);
    Inc (V, Byte ((a = t) xor (b = t)) * 10);

    GuessValue := V;
  end;

  var
    i, j, k, x, y, max, total, n: Integer;
    ww, hh, sw, sh: Integer;
    UseLines: Boolean;
begin
  // try to find tile size automatically



  UseLines := FALSE;
  if BmpW < 32 then
    TileWidth.Value := BmpW
  else
    TileWidth.Value := 32;
  if BmpH < 32 then
    TileHeight.Value := BmpH
  else
    TileHeight.Value := 32;
  HorzSpace.Value := 0;
  VertSpace.Value := 0;
  ClipLeft.Value := 0;
  ClipTop.Value := 0;

  with PreviewPicture.Canvas do
  begin
   // x := 0;
   // y := 0;
    i := 0;
    j := 0;
    k := Pixels[0, 0];
    while (i < BmpW div 16) and (ColPerc (i, k) > MOST) do
      Inc (i);
    x := i;
    while (j < BmpH div 16) and (ColPerc (j, k) > MOST) do
      Inc (j);
    y := j;
    if (x > 0) and (y > 0) and (x < BmpW div 16) and (j < BmpH div 16) then
    begin
      UseLines := TRUE;
      ClipLeft.Value := x;
      ClipTop.Value := y;

      while (i < BmpW) and (not (ColPerc (i, k) > MOST)) do
        Inc (i);
      ww := i - x;
      x := i;
      while (i < BmpW) and (ColPerc (i, k) > MOST) do
        Inc (i);
      sw := i - x;
      x := i;
      while (i < BmpW) and (not (ColPerc (i, k) > MOST)) do
        Inc (i);
      if (ww > 0) and (i - x = ww) then
        TileWidth.Value := ww;
      x := i;
      while (i < BmpW) and (ColPerc (i, k) > MOST) do
        Inc (i);
      if (sw > 0) and (i - x = sw) then
        HorzSpace.Value := sw;

      while (j < BmpH) and (not (RowPerc (j, k) > MOST)) do
        Inc (j);
      hh := j - y;
      y := j;
      while (j < BmpH) and (RowPerc (j, k) > MOST) do
        Inc (j);
      sh := j - y;
      y := j;
      while (j < BmpH) and (not (RowPerc (j, k) > MOST)) do
        Inc (j);
      if (hh > 0) and (j - y = hh) then
        TileHeight.Value := hh;
      y := j;
      while (j < BmpH) and (RowPerc (j, k) > MOST) do
        Inc (j);
      if (sh > 0) and (j - y = sw) then
        VertSpace.Value := sw;
    end;

    // try to find block size
    if not UseLines then
    begin
      ww := TileWidth.Value;
      max := 0;
      for i := 4 to BmpW div 2 do
      begin
        if BmpW mod i = 0 then
        begin
          n := 0;
          total := 0;
          for x := 1 to BmpW div i - 1 do
          begin
            for y := 0 to BmpH - 1 do
            begin
              Inc (total, GuessValue (x * i - 1, y, x * i, y));
              Inc (n);
            end;
          end;
          total := total div (n + BmpH);
          if total > Max then
          begin
            Max := total;
            ww := i;
          end;
        end;
      end;

      hh := TileHeight.Value;
      max := 0;
      for j := 4 to BmpH div 2 do
      begin
        if BmpH mod j = 0 then
        begin
          n := 0;
          total := 0;
          for y := 1 to BmpH div j - 1 do
          begin
            for x := 0 to BmpW - 1 do
            begin
              Inc (total, GuessValue (x, y * j - 1, x, y * j));
              Inc (n);
            end;
          end;
          total := total div (n + BmpW);
          if total > Max then
          begin
            Max := total;
            hh := j;
          end;
        end;
      end;
      TileWidth.Value := ww;
      TileHeight.Value := hh;
    end;
  end;

  UpdatePreview(Sender);
end;

procedure TImportTiles.TransMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Mult.Visible := FALSE;
  Trans.Caption := '';
  if Button = mbLeft then
    Trans.Color := TRANS_COLOR;
  if Button = mbRight then
  begin
    Trans.Color := clBtnFace;
    SetLength (TransList, 0);
    Trans.Caption := 'None';
  end;
end;

end.
