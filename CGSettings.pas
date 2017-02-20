unit CGSettings;

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
  StdCtrls, ExtCtrls, ComCtrls;

const
  DEFINITION_EXT = '.tsd';

function StringsToString (items: TStrings): string;

type
  TCodeGen = class(TForm)
    Memo: TMemo;
    Panel1: TPanel;
    DefinitionFile: TComboBox;
    L1: TLabel;
    OkButton: TButton;
    CancelButton: TButton;
    StatusBar1: TStatusBar;
    UseProjectDir: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure NewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DefinitionFileChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure MemoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UseProjectDirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    LastDef: string;
    LastName: string;
    LastMemoText: string;

    // 2.5
    ProjectDir: string;

    function GetCodeString: string;
    procedure ShowPos;
  end;

var
  CodeGen: TCodeGen;

implementation

uses Main;

{$R *.DFM}


function StringsToString (items: TStrings): string;
  var
    i: Integer;
    s: string;
begin
  s := #0;
  for i := 0 to items.Count - 1 do
    s := s + items.Strings[i] + #0;
  StringsToString := s;
end;

procedure TCodeGen.FormShow(Sender: TObject);
  var
    SR: TSearchRec;
    Result: Integer;
    s: string;
begin
  LastName := '';
  Memo.ReadOnly := MainForm.CDROM;
  DefinitionFile.Items.Clear;

  // 2.5

  Result := FindFirst (ProjectDir + '*' + DEFINITION_EXT, faArchive, SR);
  while Result = 0 do
  begin
    s := WithoutExt (SR.Name, DEFINITION_EXT);
    DefinitionFile.Items.Add (s);
    if LastDef = '' then
      LastDef := s;
    Result := FindNext (SR);
  end;
  FindClose (SR);

  Result := FindFirst (ApplPath + '*' + DEFINITION_EXT, faArchive, SR);
  while Result = 0 do
  begin
    s := WithoutExt (SR.Name, DEFINITION_EXT);
    if DefinitionFile.Items.IndexOf (s) = -1 then  // not already in project directory
      DefinitionFile.Items.Add (s);
    if LastDef = '' then
      LastDef := s;
    Result := FindNext (SR);
  end;
  FindClose (SR);

  s := '';
  with DefinitionFile do
  begin
    if Items.IndexOf (LastDef) > -1 then
      Text := LastDef
    else
      Text := '';
    s := Text;
  end;
  DefinitionFileChange(Sender);
  DefinitionFile.SetFocus;
  LastMemoText := StringsToString (Memo.Lines);
end;

procedure TCodeGen.NewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TCodeGen.DefinitionFileChange(Sender: TObject);
  var
    Action: TCloseAction;
begin
  if DefinitionFile.Items.IndexOf (DefinitionFile.Text) > -1 then
  begin
    Action := caHide;
    if LastName <> '' then
      FormClose (Sender, Action);
    if Action = caNone then
      Memo.SetFocus
    else
    begin
      LastName := DefinitionFile.Text;
      if FileExists (ProjectDir + LastName + DEFINITION_EXT) then
        Memo.Lines.LoadFromFile (ProjectDir + LastName + DEFINITION_EXT)
      else
        Memo.Lines.LoadFromFile (ApplPath + LastName + DEFINITION_EXT);
      LastMemoText := StringsToString (Memo.Lines);
    end;
  end
  else
    LastName := DefinitionFile.Text;

  UseProjectDir.Enabled := (DefinitionFile.Items.IndexOf (LastName) = -1);
  UseProjectDir.Checked := FileExists (ProjectDir + LastName + DEFINITION_EXT);
  if MainForm.CDROM then
  begin
    Memo.ReadOnly := not UseProjectDir.Checked;
    if UseProjectDir.Enabled then
      UseProjectDir.Checked := TRUE;
  end;
end;

procedure TCodeGen.FormClose(Sender: TObject; var Action: TCloseAction);
  var
    s: string;
    i: Integer;
begin
  if StringsToString (Memo.Lines) <> LastMemoText then
  begin
    s := LastName; // DefinitionFile.Text;
    i := 0;
    if s = '' then
    while (s = '') or (DefinitionFile.Items.IndexOf (s) <> -1) do
    begin
      Inc (i);
      s := 'Untitled' + IntToStr (i);
    end;
    case MessageDlg ('Save changes to ' + s + '?', mtConfirmation,
        [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          if UseProjectDir.Checked then
            Memo.Lines.SaveToFile (ProjectDir + s + DEFINITION_EXT)
          else
            Memo.Lines.SaveToFile (ApplPath + s + DEFINITION_EXT);
          LastDef := s;
        end;
      mrNo:
        ;
      mrCancel:
        Action := caNone;
    end;
  end;
end;

procedure TCodeGen.OkButtonClick(Sender: TObject);
  var
    s: string;
begin
  s := DefinitionFile.Text;
  if (s <> '') and (DefinitionFile.Items.IndexOf (s) <> -1) then
    LastDef := s
  else
    LastMemoText := '';
  Close;
end;

procedure TCodeGen.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

function TCodeGen.GetCodeString: string;
  var
    SR: TSearchRec;
begin
  // 2.5 - first look in project directory
  if (FindFirst (ProjectDir + LastDef + DEFINITION_EXT, faArchive, SR) = 0) then
  begin
    Memo.Lines.LoadFromFile (ProjectDir + LastDef + DEFINITION_EXT);
    GetCodeString := StringsToString (Memo.Lines);
  end
  else
  begin
    FindClose (SR);
    if (FindFirst (ApplPath + LastDef + DEFINITION_EXT, faArchive, SR) = 0) then
    begin
      Memo.Lines.LoadFromFile (ApplPath + LastDef + DEFINITION_EXT);
      GetCodeString := StringsToString (Memo.Lines);
    end
    else
      GetCodeString := '';
  end;
  FindClose (SR);
end;

procedure TCodeGen.ShowPos;
begin
  StatusBar1.Panels[0].Text := Format ('Line: %d, Col: %d',
                                 [Memo.CaretPos.Y + 1, Memo.CaretPos.X + 1]);
end;

procedure TCodeGen.MemoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ShowPos;
end;

procedure TCodeGen.MemoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowPos;
end;

procedure TCodeGen.UseProjectDirClick(Sender: TObject);
begin
  with UseProjectDir do
    Checked := Checked or MainForm.CDROM;
end;

end.
