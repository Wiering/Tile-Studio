unit Settings;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TSettingsForm = class(TForm)
    L1: TLabel;
    L2: TLabel;
    X: TSpinEdit;
    Y: TSpinEdit;
    OkButton: TButton;
    CancelButton: TButton;
    procedure OkButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure XKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Result: Boolean;
  end;

var
  SettingsForm: TSettingsForm;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

procedure TSettingsForm.OkButtonClick(Sender: TObject);
begin
  Result := True;
  Close;
end;

procedure TSettingsForm.CancelButtonClick(Sender: TObject);
begin
  Result := False;
  Close;
end;

procedure TSettingsForm.XKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OkButtonClick (Sender);
  if Key = VK_ESCAPE then
    CancelButtonClick (Sender);
end;

end.
