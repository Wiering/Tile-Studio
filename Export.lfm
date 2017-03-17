object ExportTiles: TExportTiles
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Export Tiles'
  ClientHeight = 230
  ClientWidth = 232
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  object L7: TLabel
    Left = 8
    Top = 36
    Width = 86
    Height = 13
    Caption = 'Transparent color:'
  end
  object TransColor: TShape
    Left = 160
    Top = 32
    Width = 57
    Height = 22
    Hint = 'Click in the bitmap to change the transparent color'
    ParentShowHint = False
    ShowHint = True
    OnMouseDown = TransColorMouseDown
  end
  object Label1: TLabel
    Left = 8
    Top = 124
    Width = 60
    Height = 13
    Caption = 'Border color:'
  end
  object BorderColor: TShape
    Left = 160
    Top = 120
    Width = 57
    Height = 22
    OnMouseDown = BorderColorMouseDown
  end
  object Label2: TLabel
    Left = 8
    Top = 12
    Width = 117
    Height = 13
    Caption = 'Total bitmap width (max):'
  end
  object Label3: TLabel
    Left = 8
    Top = 100
    Width = 81
    Height = 13
    Caption = 'Inner border size:'
  end
  object Label4: TLabel
    Left = 8
    Top = 76
    Width = 83
    Height = 13
    Caption = 'Outer border size:'
  end
  object ExportButton: TButton
    Left = 40
    Top = 192
    Width = 73
    Height = 25
    Caption = '&Export'
    Default = True
    TabOrder = 4
    OnClick = ExportButtonClick
  end
  object CancelButton: TButton
    Left = 120
    Top = 192
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = CancelButtonClick
  end
  object MaxWidth: TSpinEdit
    Left = 160
    Top = 8
    Width = 57
    Height = 22
    MaxValue = 16384
    MinValue = 0
    TabOrder = 0
    Value = 320
    OnKeyDown = KeyDown
  end
  object Between: TSpinEdit
    Left = 160
    Top = 96
    Width = 57
    Height = 22
    MaxValue = 256
    MinValue = 0
    TabOrder = 2
    Value = 0
    OnKeyDown = KeyDown
  end
  object Edge: TSpinEdit
    Left = 160
    Top = 72
    Width = 57
    Height = 22
    MaxValue = 256
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnKeyDown = KeyDown
  end
  object TransBottomRight: TCheckBox
    Left = 8
    Top = 152
    Width = 209
    Height = 17
    Caption = 'Transparent color at bottom-right corner'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnKeyDown = KeyDown
  end
  object ColorDialog: TColorDialog
    Left = 112
    Top = 72
  end
end
