unit Export;

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
  StdCtrls, Spin, ExtCtrls;

type
  TExportTiles = class(TForm)
    L7: TLabel;
    TransColor: TShape;
    ExportButton: TButton;
    CancelButton: TButton;
    Label1: TLabel;
    BorderColor: TShape;
    Label2: TLabel;
    MaxWidth: TSpinEdit;
    ColorDialog: TColorDialog;
    Label3: TLabel;
    Between: TSpinEdit;
    Label4: TLabel;
    Edge: TSpinEdit;
    TransBottomRight: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure TransColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BorderColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    Result: Boolean;
  end;

var
  ExportTiles: TExportTiles;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

uses
  Tiles;

procedure TExportTiles.FormShow(Sender: TObject);
  const
    Initialized: Boolean = FALSE;
begin
  Result := FALSE;

  if not Initialized then
  begin
    TransColor.Brush.Color := TRANS_COLOR;
    BorderColor.Brush.Color := TRANS_COLOR;
    Initialized := TRUE;
  end;

  MaxWidth.SetFocus;
end;

procedure TExportTiles.ExportButtonClick(Sender: TObject);
begin
  Result := TRUE;
  Close;
end;

procedure TExportTiles.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TExportTiles.TransColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := TransColor.Brush.Color;
  if ColorDialog.Execute then
    TransColor.Brush.Color := ColorDialog.Color;
end;

procedure TExportTiles.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then
    ExportButtonClick (Sender);
  if key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

procedure TExportTiles.BorderColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ColorDialog.Color := BorderColor.Brush.Color;
  if ColorDialog.Execute then
    BorderColor.Brush.Color := ColorDialog.Color;
end;

end.
