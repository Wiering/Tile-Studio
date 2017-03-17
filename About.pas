unit About;

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
  ExtCtrls, StdCtrls;

type
  TAboutForm = class(TForm)
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Label3: TLabel;
    WebSite: TLabel;
    Image1: TImage;
    Label6: TLabel;
    procedure OKButtonClick(Sender: TObject);
    procedure OKButtonKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure WebSiteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

uses
{$IFnDEF FPC}
  ShellApi,
{$ELSE}

{$ENDIF}
  Main;


procedure TAboutForm.OKButtonClick(Sender: TObject);
begin
  Close
end;

procedure TAboutForm.OKButtonKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  if Version.Caption = 'Version' then
    Version.Caption := Version.Caption + ' ' + Main.VERSION_NUMBER;
  if Caption = 'About' then
    Caption := Caption + ' ' + APPL_NAME;
  Label1.Caption := APPL_NAME;
  Label2.Caption := APPL_NAME;
end;

procedure TAboutForm.WebSiteClick(Sender: TObject);
  var
    Param: string;
    URL: string;
begin
  Param := URL;
  URL := WebSite.Caption;
  {$IFDEF FPC}
   OpenDocument(URL);
  {$ELSE}
   ShellExecute(0, 'OPEN', PChar(URL), '', '', SW_SHOWNORMAL);
  {$ENDIF}
end;

end.
