object MapCode: TMapCode
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Map Code'
  ClientHeight = 127
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  object L1: TLabel
    Left = 8
    Top = 52
    Width = 97
    Height = 13
    Caption = 'Map Code (decimal):'
  end
  object L2: TLabel
    Left = 8
    Top = 20
    Width = 120
    Height = 13
    Caption = 'Map Code (hexadecimal):'
  end
  object DecCode: TSpinEdit
    Left = 152
    Top = 48
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnChange = CheckDecCode
    OnKeyDown = MapCodeKeyDown
  end
  object HexCode: TEdit
    Left = 152
    Top = 16
    Width = 57
    Height = 21
    TabOrder = 0
    Text = '0'
    OnChange = HexCodeChange
    OnKeyDown = MapCodeKeyDown
  end
  object OkButton: TButton
    Left = 32
    Top = 91
    Width = 73
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 112
    Top = 91
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = CancelButtonClick
  end
end
