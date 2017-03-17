unit TileCopy;

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

  {$I settings.inc}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin;

type
  TCopyTilesForm = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    G1: TGroupBox;
    L1: TLabel;
    L3: TLabel;
    L4: TLabel;
    Src: TComboBox;
    StartTile: TSpinEdit;
    TileCount: TSpinEdit;
    G2: TGroupBox;
    L2: TLabel;
    Dst: TComboBox;
    L5: TLabel;
    DstStartTile: TSpinEdit;
    Overwrite: TCheckBox;
    Stretch: TCheckBox;
    CopyBounds: TCheckBox;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckInput(Sender: TObject);
    procedure CopyTilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Result: Boolean;
  end;

var
  CopyTilesForm: TCopyTilesForm;

implementation

uses Main;

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TCopyTilesForm.OkButtonClick(Sender: TObject);
begin
  if Src.Items.IndexOf (Src.Text) < 0 then
  begin
    MessageDlg ('Source Tile Set doesn'#39't exist.', mtError, [mbOk], 0);
    Src.SetFocus;
    Exit;
  end;
  if Dst.Items.IndexOf (Dst.Text) < 0 then
  begin
    MessageDlg ('Destination Tile Set doesn'#39't exist.', mtError, [mbOk], 0);
    Dst.SetFocus;
    Exit;
  end;


//  MessageDlg ('Not yet implemented.', mtError, [mbOk], 0);

  Result := TRUE;
  Close;
end;

procedure TCopyTilesForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TCopyTilesForm.FormShow(Sender: TObject);
begin
  Result := FALSE;
  Src.SetFocus;
  CheckInput (Sender);
end;

procedure TCopyTilesForm.CheckInput(Sender: TObject);
  var
    i, j, W, H: Integer;
begin
  i := Src.Items.IndexOf (Src.Text);
  if i >= 0 then
  begin
    with MainForm.TileTab[i] do
      if Sender = Src then
      begin
        StartTile.MinValue := 1;
        StartTile.Value := tbr.Current + 1;
        StartTile.MaxValue := tbr.TileCount;
        TileCount.Value := tbr.TileCount - tbr.Current;
        TileCount.MaxValue := tbr.TileCount;
      end;
  end;

  i := Dst.Items.IndexOf (Dst.Text);
  if i >= 0 then
  begin
    with MainForm.TileTab[i] do
    begin
      if Sender = Dst then
      begin
        DstStartTile.Value := tbr.Current + 1;
        DstStartTile.MaxValue := tbr.TileCount;
      end;
      W := tbr.W;
      H := tbr.H;
      j := Src.Items.IndexOf (Src.Text);
      if j >= 0 then
        with MainForm.TileTab[j] do
          Stretch.Enabled := (tbr.W <> W) or (tbr.H <> H);
    end;
  end;

end;

procedure TCopyTilesForm.CopyTilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OkButtonClick (Sender);
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

end.
