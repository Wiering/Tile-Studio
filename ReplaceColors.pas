unit ReplaceColors;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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
  
interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin;

type
  TReplace = class(TForm)
    ColorDialog: TColorDialog;
    G1: TGroupBox;
    L1: TLabel;
    L3: TLabel;
    TolGreen: TSpinEdit;
    FindColor1: TShape;
    FindRange: TCheckBox;
    FindColor2: TShape;
    Label1: TLabel;
    TolRed: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    TolBlue: TSpinEdit;
    G2: TGroupBox;
    Label4: TLabel;
    ReplaceColor1: TShape;
    ReplaceColor2: TShape;
    ReplaceRange: TCheckBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    AddBlue: TSpinEdit;
    AddGreen: TSpinEdit;
    AddRed: TSpinEdit;
    CurrentTileOnly: TButton;
    ReplaceAll: TButton;
    Cancel: TButton;
    Label9: TLabel;
    procedure CancelClick(Sender: TObject);
    procedure CurrentTileOnlyClick(Sender: TObject);
    procedure ReplaceAllClick(Sender: TObject);
    procedure FindRangeClick(Sender: TObject);
    procedure ReplaceRangeClick(Sender: TObject);
    procedure ColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    CurColor: Integer;
    Result: Boolean;
    All: Boolean;
  end;

var
  Replace: TReplace;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TReplace.CancelClick(Sender: TObject);
begin
  Result := FALSE;
  Close;
end;

procedure TReplace.CurrentTileOnlyClick(Sender: TObject);
begin
  All := FALSE;
  Result := TRUE;
  Close;
end;

procedure TReplace.ReplaceAllClick(Sender: TObject);
begin
  All := TRUE;
  Result := TRUE;
  Close;
end;

procedure TReplace.FindRangeClick(Sender: TObject);
begin
  FindColor2.Visible := FindRange.Checked;
end;

procedure TReplace.ReplaceRangeClick(Sender: TObject);
begin
  ReplaceColor2.Visible := ReplaceRange.Checked;
end;

procedure TReplace.ColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with Sender as TShape do
  begin
    if Button = mbRight then
      if TShape(Sender).Brush.Color <> CurColor then
      begin
        TShape(Sender).Brush.Color := CurColor;
        Exit;
      end;
    ColorDialog.Color := TShape(Sender).Brush.Color;
    if ColorDialog.Execute then
      TShape(Sender).Brush.Color := ColorDialog.Color;
  end;
end;

end.
