unit PalMan;

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
  StdCtrls, ExtCtrls, ComCtrls, Spin;

const
  DEFAULT_PAL_SIZE = 256;
  DEFAULT_PRESET   = 128;

type
  TPaletteManager = class(TForm)
    TopPanel: TPanel;
    PaletteTab: TTabControl;
    BottomPanel: TPanel;
    PaletteColors: TPaintBox;
    NewButton: TButton;
    CloseButton: TButton;
    DeleteButton: TButton;
    L1: TLabel;
    L0: TLabel;
    PaletteSize: TSpinEdit;
    Identifier: TEdit;
    L2: TLabel;
    Preset: TSpinEdit;
    ColorDialog1: TColorDialog;
    ImportButton: TButton;
    GenerateButton: TButton;
    ExportButton: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    RGBDepthGroupBox: TGroupBox;
    edR: TSpinEdit;
    L3: TLabel;
    L4: TLabel;
    edG: TSpinEdit;
    L5: TLabel;
    edB: TSpinEdit;
    UseThisPalette: TCheckBox;
    SetAsDefault: TCheckBox;
    CopyButton: TButton;
    PasteButton: TButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure PaletteColorsPaint(Sender: TObject);
    procedure PaletteSizeChange(Sender: TObject);
    procedure PresetChange(Sender: TObject);
    procedure PaletteTabChange(Sender: TObject);
    procedure PaletteColorsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure IdentifierChange(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure ImportButtonClick(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
    procedure edChange(Sender: TObject);
    procedure UseThisPaletteClick(Sender: TObject);
    procedure SetAsDefaultClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
    procedure PasteButtonClick(Sender: TObject);
  private
    { Private declarations }
    function CheckRGBDepth: Boolean;
    procedure EnableDisable;
    function MakePalName: string;
  public
    { Public declarations }
    procedure ClearPalettes;
    procedure ImportPalette (Filename: string; tab: Integer; PalType: Integer);
    function GetID (n: Integer): string;
    procedure setID (n: Integer; NewID: string);

  end;

var
  PaletteManager: TPaletteManager;

var
  aaiPal: array of array of Integer;
  aiPalSize: array of Integer;
  aiPreset: array of Integer;
  aiOrig: array of Integer;
  aiUsedColors: array of Integer;
  aiClip: array of Integer;

const
  DefaultPalette: Integer = -1;
  SelectedPalette: Integer = -1;

var
  DefaultPaletteChanged,
  SelectedPaletteChanged: Boolean;

implementation

uses Main;

{$R *.DFM}

var
  LastColor: Integer;

procedure TPaletteManager.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TPaletteManager.FormShow(Sender: TObject);
begin
  if (SelectedPalette > -1) and (SelectedPalette < PaletteTab.Tabs.Count) then
    PaletteTab.TabIndex := SelectedPalette;   // 2.34 - start with selected palette

  EnableDisable;
  CloseButton.SetFocus;
  if PaletteTab.Tabs.Count > 0 then
  begin

    PaletteTabChange (Sender);
    PaletteTab.Repaint;
  end;
end;

function TPaletteManager.MakePalName: string;
  var
    i: Integer;
    s: string;
begin
  i := 0;
  repeat
    Inc (i);
    s := 'Palette' + IntToStr (i);
  until PaletteTab.Tabs.IndexOf (s) = -1;
  MakePalName := s;
end;

procedure TPaletteManager.NewButtonClick(Sender: TObject);
  var
    i, j, k: Integer;
    s: string;
begin
  s := MakePalName;
  i := PaletteTab.Tabs.Count;
  SetLength (aaiPal, i + 1);
  SetLength (aaiPal[i], DEFAULT_PAL_SIZE);
  for j := 0 to 255 do
    aaiPal[i, j] := clWhite;
  SetLength (aiPalSize, i + 1);
  aiPalSize[i] := DEFAULT_PAL_SIZE;
  SetLength (aiPreset, i + 1);
  aiPreset[i] := DEFAULT_PRESET;
  SetLength (aiOrig, i + 1);
  aiOrig[i] := -1;

  k := Length (aiUsedColors);
  if k <> 0 then
  begin
 //   SetLength (aaiPal[i], k);
    for j := 0 to k - 1 do
      aaiPal[i, j] := aiUsedColors[j];
    aiPalSize[i] := k;
    aiPreset[i] := k;
  end;

  PaletteTab.Tabs.Add (s);
  with PaletteTab do
    TabIndex := Tabs.IndexOf (s);

  if Sender <> nil then
  begin
    PaletteSize.Value := aiPalSize[i];
    Preset.Value := aiPreset[i];


    EnableDisable;

    if k = 0 then
    begin
      PaletteSize.Value := DEFAULT_PAL_SIZE;
      Preset.Value := DEFAULT_PRESET;
    end;

    SetAsDefault.Checked := FALSE;
    UseThisPalette.Checked := FALSE;
  end;
end;

function TPaletteManager.CheckRGBDepth: Boolean;
begin
  try
    CheckRGBDepth := (edR.Value * edG.Value * edB.Value) <= 256;
  except
    CheckRGBDepth := FALSE;
  end;
end;

procedure TPaletteManager.EnableDisable;
  var
    b: Boolean;
begin
  b := PaletteTab.Tabs.Count > 0;
  if b and (PaletteTab.TabIndex < 0) then
    PaletteTab.TabIndex := 0;
  DeleteButton.Enabled := b;
  Identifier.Enabled := b;
  PaletteSize.Enabled := b;
  Preset.Enabled := b;
  ImportButton.Enabled := b;
  ExportButton.Enabled := b;
  SetAsDefault.Enabled := b;
  UseThisPalette.Enabled := b;
  edR.Enabled := b;
  edG.Enabled := b;
  edB.Enabled := b;
  CopyButton.Enabled := b and (PaletteSize.Value > 0);
  PasteButton.Enabled := b and (Length (aiClip) > 0);

  GenerateButton.Enabled := b and CheckRGBDepth;
  if b then
  begin
    Identifier.Text := PaletteTab.Tabs.Strings[PaletteTab.TabIndex]
  end
  else
  begin
    Identifier.Text := '';
  end;
end;

procedure TPaletteManager.DeleteButtonClick(Sender: TObject);
  var
    i, j, k: Integer;
begin
  with PaletteTab do
  begin
    if MessageDlg ('Delete palette "' + Tabs[TabIndex] + '"?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      if SelectedPalette = TabIndex then
        SelectedPalette := -1
      else
        if SelectedPalette > TabIndex then
          Dec (SelectedPalette);
      if DefaultPalette = TabIndex then
        DefaultPalette := -1
      else
        if DefaultPalette > TabIndex then
          Dec (DefaultPalette);

      for k := TabIndex to (Tabs.Count - 1) - 1 do
      begin
        SetLength (aaiPal[k], Length (aaiPal[k + 1]));
        Tabs[k] := Tabs[k + 1];
        for i := 0 to Length (aaiPal[k]) - 1 do
          aaiPal[k, i] := aaiPal[k + 1, i];
        aiPalSize[k] := aiPalSize[k + 1];
        aiPreset[k] := aiPreset[k + 1];
        aiOrig[k] := aiOrig[k + 1];
      end;
      j := TabIndex;
      i := Tabs.Count - 1;
      Tabs.Delete (i);
      SetLength (aaiPal[i], 0);
      SetLength (aaiPal, i);
      SetLength (aiPalSize, i);
      SetLength (aiPreset, i);
      SetLength (aiOrig, i);
      if j - 1 >= 0 then
        TabIndex := j - 1
      else
        TabIndex := 0;
      EnableDisable;
      PaletteTabChange (Sender);
    end;
  end;
//  PaletteColors.Repaint;
end;

procedure TPaletteManager.PaletteColorsPaint(Sender: TObject);
  var
    CW, CH: Integer;
    X, Y, W, H, Wd, Ht, NH, NV: Integer;
    i, j: Integer;
    n, tab: Integer;
begin
  tab := PaletteTab.TabIndex;
  if tab >= 0 then
  begin
    CW := PaletteTab.ClientWidth - 2 * 5;
    CH := PaletteTab.ClientHeight - BottomPanel.Height - 16 - 2 * 7;
    NH := 16;
    NV := 16;
    W := CW div NH;
    H := CH div NV;
    Wd := W * NH;
    Ht := H * NV;
    X := (CW - Wd) div 2;
    Y := (CH - Ht) div 2;
    n := 0;
  //  with PaletteColors.Canvas do
  //    Rectangle (0, 0, CW + 1, CH + 1);
    for j := 0 to NV - 1 do
      for i := 0 to NH - 1 do
      begin
        with PaletteColors.Canvas do
        begin
          Pen.Color := clBlack;
          Pen.Style := psSolid;
          if n < Length (aaiPal[tab]) then  // bug fix 4.42
          begin
            if n < aiPreset[tab] then
              Brush.Color := aaiPal[tab, n]
            else
              Brush.Color := clBtnFace;
            Brush.Style := bsSolid;
            if n < aiPalSize[tab] then
              Rectangle (X + i * W, Y + j * H,
                         X + (i + 1) * W + 1, Y + (j + 1) * H + 1);
          end;
        end;
        Inc (n);
      end;
  end;
end;

procedure TPaletteManager.PaletteSizeChange(Sender: TObject);
begin
  try
    aiPalSize[PaletteTab.TabIndex] := PaletteSize.Value;
    SetLength (aaiPal[PaletteTab.TabIndex], PaletteSize.Value);
  finally
    PaletteColors.Repaint;
  end;
end;

procedure TPaletteManager.PresetChange(Sender: TObject);
begin
  try
    aiPreset[PaletteTab.TabIndex] := Preset.Value;
    if Preset.Value > PaletteSize.Value then
    begin
      aiPalSize[PaletteTab.TabIndex] := PaletteSize.Value;
      PaletteSize.Value := Preset.Value;
      SetLength (aaiPal[PaletteTab.TabIndex], PaletteSize.Value);
    end;
  finally
    PaletteColors.Repaint;
  end;
end;

procedure TPaletteManager.PaletteTabChange(Sender: TObject);
  var
    tab: Integer;
begin
  tab := PaletteTab.TabIndex;
  if tab <> -1 then
  begin
    Identifier.Text := PaletteTab.Tabs.Strings[tab];
    PaletteSize.Value := aiPalSize[tab];
    Preset.Value := aiPreset[tab];
  end;

  UseThisPalette.Checked := tab = SelectedPalette;
  SetAsDefault.Checked := tab = DefaultPalette;

  LastColor := -1;

  PaletteColors.Repaint;
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

procedure Fade (tab, n1, n2: Integer);
  var
    Start, Count: Integer;
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;
    i, C: Integer;
begin
  if n2 > n1 then
    Start := n1
  else
    Start := n2;
  Count := Abs (n2 - n1) + 1;
  if Count < 3 then
    Exit;
  GetRGB (aaiPal[tab, Start], R1, G1, B1);
  GetRGB (aaiPal[tab, Start + Count - 1], R2, G2, B2);
  for i := 0 to Count - 1 do
  begin
    C := RGB (R1 + i * (R2 - R1) div (Count - 1),
              G1 + i * (G2 - G1) div (Count - 1),
              B1 + i * (B2 - B1) div (Count - 1));
    aaiPal[tab, Start + i] := C;
  end;
end;

procedure TPaletteManager.PaletteColorsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    CW, CH: Integer;
    XP, YP, W, H, Wd, Ht, NH, NV: Integer;
    n, tab: Integer;
begin
  tab := PaletteTab.TabIndex;
  if tab >= 0 then
  begin
    CW := PaletteTab.ClientWidth - 2 * 5;
    CH := PaletteTab.ClientHeight - BottomPanel.Height - 16 - 2 * 7;
    NH := 16;
    NV := 16;
    W := CW div NH;
    H := CH div NV;
    Wd := W * NH;
    Ht := H * NV;
    XP := (CW - Wd) div 2;
    YP := (CH - Ht) div 2;

    n := (X - XP) div W + (Y - YP) div H * 16;

    if n < aiPreset[tab] then
    begin
      if Button = mbLeft then
        ColorDialog1.Color := aaiPal[tab, n];
      if ColorDialog1.Execute then
      begin
        aaiPal[tab, n] := ColorDialog1.Color;

        if ssShift in Shift then
          if LastColor > -1 then
            Fade (tab, LastColor, n);

        PaletteColors.Repaint;
        LastColor := n;
      end;
    end;
  end;

end;

procedure TPaletteManager.IdentifierChange(Sender: TObject);
  var
    i: Integer;
    s: string;
begin
  if PaletteTab.TabIndex = -1 then
    Exit;
  s := Identifier.Text;
  for i := Length (s) downto 1 do
    if not (s[i] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) then
      Delete (s, i, 1);
  with PaletteTab do
    for i := 0 to Tabs.Count - 1 do
      if i <> TabIndex then
        if Tabs.Strings[i] = s then
          s := '';
  if s = '' then
    s := MakePalName;
  PaletteTab.Tabs.Strings[PaletteTab.TabIndex] := s;
end;

procedure TPaletteManager.GenerateButtonClick(Sender: TObject);
  var
    R, G, B: Integer;
    RR, GG, BB: Integer;
    Total, n: Integer;
    tab: Integer;
  {  i, j, k: Integer;
    R1, G1, B1: Integer;
    R2, G2, B2: Integer;  }
begin
  tab := PaletteTab.TabIndex;
  if (tab >= 0) and (CheckRGBDepth) then
  begin
    RR := edR.Value;
    GG := edG.Value;
    BB := edB.Value;
    Total := RR * GG * BB;
    PaletteSize.Value := Total;
    Preset.Value := Total;
    SetLength (aaiPal[tab], Total);
    n := 0;
    for r := 0 to RR - 1 do
      for g := 0 to GG - 1 do
        for b := 0 to BB - 1 do
        begin
          aaiPal[tab, n] := RGB (r * 255 div (RR - 1),
                                 g * 255 div (GG - 1),
                                 b * 255 div (BB - 1));
          Inc (n)
        end;
  end;
  {
  for i := 0 to 215 do
    for j := i + 1 to 215 do
    begin
      GetRGB (aaiPal[tab, i], R1, G1, B1);
      GetRGB (aaiPal[tab, j], R2, G2, B2);
      if R1 * R1 + G1 * G1 + B1 * B1 > R2 * R2 + G2 * G2 + B2 * B2 then
      begin
        k := aaiPal[tab, i];
        aaiPal[tab, i] := aaiPal[tab, j];
        aaiPal[tab, j] := k;
      end;
    end;
  }
  PaletteColors.Repaint;
end;


procedure TPaletteManager.ImportPalette (Filename: string; tab: Integer; PalType: Integer);
  var
    R, G, B: Byte;
    n: Integer;
    F: file of Byte;
    C0, C1: Byte;
begin
  SetLength (aaiPal[tab], DEFAULT_PAL_SIZE);
  AssignFile (F, Filename);
  n := 0;
  try
    Reset (F);
    repeat
      case PalType of
        1: begin   // 8 bit
             Read (F, R);
             Read (F, G);
             Read (F, B);
             aaiPal[tab, n] := RGB (R, G, B);
           end;
        2: begin   // 6 bit
             Read (F, R);
             Read (F, G);
             Read (F, B);
             aaiPal[tab, n] := RGB ((R shl 2) and $FF, (G shl 2) and $FF, (B shl 2) and $FF);
           end;
        3: begin   // 5 bit
             Read (F, C0);
             Read (F, C1);
             aaiPal[tab, n] :=
                RGB (((C0)                          and $1F) shl 3,
                     ((C0 shr 5 + (C1 and 3) shl 3) and $1F) shl 3,
                     ((C1 shr 2)                    and $1F) shl 3);
           end;
      end;
      Inc (n);
    until (n >= DEFAULT_PAL_SIZE) or eof (F);
  finally
    PaletteSize.Value := n;
    Preset.Value := n;
    CloseFile (F);
  end;
end;

procedure TPaletteManager.ImportButtonClick(Sender: TObject);
  var
    tab: Integer;
begin
  tab := PaletteTab.TabIndex;
  if tab >= 0 then
    if OpenDialog1.Execute then
    begin
      ImportPalette (OpenDialog1.FileName, tab, OpenDialog1.FilterIndex);
      PaletteColors.Repaint;
    end;
end;

procedure TPaletteManager.ExportButtonClick(Sender: TObject);
  var
    R, G, B, c: Integer;
    tab: Integer;
    n: Integer;
    F: file of Byte;
    C0, C1: Byte;
begin
  tab := PaletteTab.TabIndex;
  if tab >= 0 then
    if SaveDialog1.Execute then
    begin
      AssignFile (F, SaveDialog1.Filename);
      try
        ReWrite (F);
        for n := 0 to aiPalSize[tab] - 1 do
        begin
          GetRGB (aaiPal[tab, n], R, G, B);
          case SaveDialog1.FilterIndex of
            1: begin
                 Write (F, R);
                 Write (F, G);
                 Write (F, B);
               end;
            2: begin
                 R := R shr 2;
                 G := G shr 2;
                 B := B shr 2;
                 Write (F, R);
                 Write (F, G);
                 Write (F, B);
               end;
            3: begin
                 c := (R shr 3) and $1F +
                     ((G shr 3) and $1F) shl 5 +
                     ((B shr 3) and $1F) shl 10;
                 C0 := Lo (c);
                 C1 := Hi (c);

                 Write (F, C0);
                 Write (F, C1);
               end;
          end;
        end;
      finally
        CloseFile (F);
      end;
      PaletteColors.Repaint;
    end;
end;

procedure TPaletteManager.edChange(Sender: TObject);
begin
  GenerateButton.Enabled := CheckRGBDepth;
end;

procedure TPaletteManager.UseThisPaletteClick(Sender: TObject);
begin
  if UseThisPalette.Checked then
    SelectedPalette := PaletteTab.TabIndex;
  SelectedPaletteChanged := TRUE;
end;

procedure TPaletteManager.SetAsDefaultClick(Sender: TObject);
begin
  if SetAsDefault.Checked then
    DefaultPalette := PaletteTab.TabIndex;
  DefaultPaletteChanged := TRUE;
end;

procedure TPaletteManager.ClearPalettes;
  var
    i: Integer;
begin
  for i := PaletteTab.Tabs.Count - 1 downto 0 do
    PaletteTab.Tabs.Delete (i);
  for i := 0 to Length (aaiPal) - 1 do
    SetLength (aaiPal[i], 0);
  SetLength (aiPalSize, 0);
  SetLength (aiPreset, 0);
  SetLength (aiOrig, 0);
  DefaultPalette := -1;
  SelectedPalette := -1;
end;

function TPaletteManager.GetID (n: Integer): string;
begin
  if PaletteTab.Tabs.Count = 0 then   // 2.32
    GetID := ''
  else
    if not (n in [0..PaletteTab.Tabs.Count - 1]) then
      GetID := ''
    else
      GetID := PaletteTab.Tabs.Strings[n];
end;

procedure TPaletteManager.setID (n: Integer; NewID: string);
begin
  if n >= PaletteTab.Tabs.Count then
    PaletteTab.Tabs.Add (NewID)
  else
    PaletteTab.Tabs.Strings[n] := NewID;
end;

procedure TPaletteManager.CopyButtonClick(Sender: TObject);
  var
    tab: Integer;
    i: Integer;
begin
  tab := PaletteTab.TabIndex;
  if tab >= 0 then
  begin
    SetLength (aiClip, aiPreset[tab]);
    for i := 0 to aiPreset[tab] - 1 do
      aiClip[i] := aaiPal[tab, i];
    EnableDisable;
  end;
end;

procedure TPaletteManager.PasteButtonClick(Sender: TObject);
  var
    i: Integer;
    tab: Integer;
begin
  tab := PaletteTab.TabIndex;
  i := 0;
  if tab >= 0 then
    while (i < Length (aiClip)) and (aiPreset[tab] < 256) do
    begin
      aaiPal[tab, aiPreset[tab]] := aiClip[i];
      Inc (aiPreset[tab]);
      if aiPreset[tab] > aiPalSize[tab] then
        aiPalSize[tab] := aiPreset[tab];
      Inc (i);
    end;
  PaletteTabChange (Sender);
  PaletteTab.Repaint;
end;

end.
