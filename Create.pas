unit Create;

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
  StdCtrls, Spin;

type
  TNewMode = (nmNewTileSet, nmTileSetProperties,
              nmNewMap, nmMapProperties);

type
  TNewForm = class(TForm)
    L1: TLabel;
    L2: TLabel;
    L0: TLabel;
    TileWidth: TSpinEdit;
    TileHeight: TSpinEdit;
    Identifier: TEdit;
    OkButton: TButton;
    CancelButton: TButton;
    NH: TSpinEdit;
    NV: TSpinEdit;
    L3: TLabel;
    Overlap: TSpinEdit;
    Skip: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure IdentifierKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OverlapEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    NewMode: TNewMode;
    DefaultName: string;
    CanChangeSize,
    CreateNew: Boolean;
    Result: Boolean;
    DefaultOverlap: Integer;

  end;

var
  NewForm: TNewForm;

implementation

uses Main;

{$R *.DFM}

procedure TNewForm.FormShow(Sender: TObject);
begin
  Result := FALSE;
  Overlap.Enabled := TRUE;
  Overlap.Value := DefaultOverlap;
  case NewMode of
    nmNewTileSet:
      begin
        Caption := 'New Tile Set';
        CreateNew := TRUE;
        L3.Enabled := TRUE;
      end;
    nmTileSetProperties:
      begin
        Caption := 'Tile Set Properties';
        CreateNew := FALSE;
        L3.Enabled := TRUE;
      end;
    nmNewMap:
      begin
        Caption := 'New Map';
        CreateNew := TRUE;
        L3.Enabled := FALSE;
        Overlap.Enabled := FALSE;
      end;
    nmMapProperties:
      begin
        Caption := 'Map Properties';
        CreateNew := FALSE;
        L3.Enabled := FALSE;
        Overlap.Enabled := FALSE;
      end;
  end;

  if NewMode in [nmNewTileSet, nmTileSetProperties] then
  begin
    L1.Caption := 'Tile Width:';
    L2.Caption := 'Tile Height:';
    NH.Visible := FALSE;
    NV.Visible := FALSE;
    TileWidth.Visible := TRUE;
    TileHeight.Visible := TRUE;
  end
  else
  begin
    L1.Caption := 'Number of tiles horizontally:';
    L2.Caption := 'Number of tiles vertically:';
    TileWidth.Visible := FALSE;
    TileHeight.Visible := FALSE;
    NH.Visible := TRUE;
    NV.Visible := TRUE;
  end;

  Identifier.Text := DefaultName;
  if CreateNew then
  begin
    TileWidth.Enabled := TRUE;
    TileHeight.Enabled := TRUE;
  end
  else
  begin
    TileWidth.Enabled := CanChangeSize;
    TileHeight.Enabled := CanChangeSize;
  end;
  Identifier.SetFocus;
end;

procedure TNewForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TNewForm.OkButtonClick(Sender: TObject);
begin
  if (NH.Enabled and (NH.Value <= 0)) or
     (NV.Enabled and (NV.Value <= 0)) or
     (TileWidth.Enabled and (TileWidth.Value <= 0)) or
     (TileHeight.Enabled and (TileHeight.Value <= 0)) then
    MessageDlg ('One or more values are invalid.', mtWarning, [mbOk], 0)
  else
    if MainForm.TCNameOK (Identifier.Text, not CreateNew) then
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

procedure TNewForm.IdentifierKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OkButtonClick (Sender);
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

procedure TNewForm.OverlapEnter(Sender: TObject);
begin
  Overlap.MinValue := 0;
  Overlap.MaxValue := TileHeight.Value - 1;
end;

end.
