unit SelectDir;

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
  LCLIntf, LCLType, LMessages, ShellCtrls,
{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TOutputDir = class(TForm)
    OkButton: TButton;
    CancelButton: TButton;
    {$IFDEF FPC}
      ShellTreeView: TShellTreeView;
    {$ELSE}
      DirectoryListBox: TDirectoryListBox;
      DriveComboBox: TDriveComboBox;
    {$ENDIF}
    L2: TLabel;
    L1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Result: Boolean;
  end;

var
  OutputDir: TOutputDir;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TOutputDir.FormShow(Sender: TObject);
begin
  Result := FALSE;
  {$IFDEF FPC}
    ShellTreeView.SetFocus;
  {$ELSE}
    DirectoryListBox.SetFocus;
  {$ENDIF}
end;

procedure TOutputDir.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TOutputDir.OkButtonClick(Sender: TObject);
begin
  Result := TRUE;
  Close;
end;

procedure TOutputDir.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
  if Key = VK_RETURN then
    OKButtonClick (Sender);
end;

end.
