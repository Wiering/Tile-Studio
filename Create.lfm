object NewForm: TNewForm
  Left = 829
  Top = 588
  BorderStyle = bsDialog
  ClientHeight = 181
  ClientWidth = 218
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
    Top = 44
    Width = 51
    Height = 13
    Caption = 'Tile Width:'
  end
  object L2: TLabel
    Left = 8
    Top = 68
    Width = 54
    Height = 13
    Caption = 'Tile Height:'
  end
  object L0: TLabel
    Left = 8
    Top = 12
    Width = 43
    Height = 13
    Caption = 'Identifier:'
  end
  object L3: TLabel
    Left = 8
    Top = 92
    Width = 76
    Height = 13
    Caption = 'Vertical overlap:'
  end
  object TileWidth: TSpinEdit
    Left = 152
    Top = 40
    Width = 57
    Height = 22
    MaxValue = 1024
    MinValue = 1
    TabOrder = 1
    Value = 32
    OnKeyDown = IdentifierKeyDown
  end
  object TileHeight: TSpinEdit
    Left = 152
    Top = 64
    Width = 57
    Height = 22
    MaxValue = 1024
    MinValue = 1
    TabOrder = 3
    Value = 32
    OnKeyDown = IdentifierKeyDown
  end
  object Identifier: TEdit
    Left = 88
    Top = 8
    Width = 121
    Height = 21
    TabOrder = 0
    OnKeyDown = IdentifierKeyDown
  end
  object OkButton: TButton
    Left = 32
    Top = 147
    Width = 73
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 6
    OnClick = OkButtonClick
  end
  object CancelButton: TButton
    Left = 112
    Top = 147
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = CancelButtonClick
  end
  object NH: TSpinEdit
    Left = 152
    Top = 40
    Width = 57
    Height = 22
    MaxValue = 1024
    MinValue = 1
    TabOrder = 2
    Value = 1
    OnKeyDown = IdentifierKeyDown
  end
  object NV: TSpinEdit
    Left = 152
    Top = 64
    Width = 57
    Height = 22
    MaxValue = 1024
    MinValue = 1
    TabOrder = 4
    Value = 1
    OnKeyDown = IdentifierKeyDown
  end
  object Overlap: TSpinEdit
    Left = 152
    Top = 88
    Width = 57
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 0
    OnEnter = OverlapEnter
    OnKeyDown = IdentifierKeyDown
  end
  object Skip: TCheckBox
    Left = 8
    Top = 120
    Width = 201
    Height = 17
    Caption = 'Skip for code generation'
    TabOrder = 8
  end
end
