unit MCEdit;

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

const
  MAX_CODE = 255;

type
  TMapCode = class(TForm)
    L1: TLabel;
    L2: TLabel;
    DecCode: TSpinEdit;
    HexCode: TEdit;
    OkButton: TButton;
    CancelButton: TButton;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CheckDecCode(Sender: TObject);
    procedure HexCodeChange(Sender: TObject);
    procedure MapCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    OldValue,
    Value: Integer;
    Result: Boolean;
    SkipUpdate: Boolean;
  end;

var
  MapCode: TMapCode;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

uses
  HEX;

procedure TMapCode.OkButtonClick(Sender: TObject);
begin
  Result := TRUE;
  Close;
end;

procedure TMapCode.CancelButtonClick(Sender: TObject);
begin
  Value := OldValue;
  Result := FALSE;
  Close;
end;

procedure TMapCode.FormShow(Sender: TObject);
begin
  Result := FALSE;
  OldValue := Value;
  HexCode.Text := Hex2 (Value);
  DecCode.Text := IntToStr (Value);
  SkipUpdate := FALSE;
  HexCode.SetFocus;
end;

procedure TMapCode.CheckDecCode(Sender: TObject);
  var
    n, c: Integer;
begin
  if SkipUpdate then
    Exit;
  Val (DecCode.Text, n, c);
  if (c = 0) and (n >= 0) and (n <= MAX_CODE) then
  begin
    SkipUpdate := TRUE;
    HexCode.Text := Hex2 (n);
    SkipUpdate := FALSE;
    Value := n;
    OkButton.Enabled := TRUE;
  end
  else
    OkButton.Enabled := FALSE;
end;

procedure TMapCode.HexCodeChange(Sender: TObject);
  var
    n, c: Integer;
begin
  if SkipUpdate then
    Exit;
  Val ('$' + HexCode.Text, n, c);
  if (c = 0) and (n >= 0) and (n <= MAX_CODE) then
  begin
    SkipUpdate := TRUE;
    DecCode.Text := IntToStr (n);
    SkipUpdate := FALSE;
    Value := n;
    OkButton.Enabled := TRUE;
  end
  else
    OkButton.Enabled := FALSE;
end;

procedure TMapCode.MapCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OkButtonClick (Sender);
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

end.
