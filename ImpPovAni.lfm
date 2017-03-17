object PovAni: TPovAni
  Left = 201
  Top = 477
  BorderStyle = bsDialog
  Caption = 'Import PovRay animation'
  ClientHeight = 217
  ClientWidth = 300
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
    Left = 96
    Top = 12
    Width = 22
    Height = 13
    Caption = 'First:'
  end
  object L2: TLabel
    Left = 200
    Top = 12
    Width = 23
    Height = 13
    Caption = 'Last:'
  end
  object Dimensions: TLabel
    Left = 8
    Top = 40
    Width = 3
    Height = 13
    Alignment = taCenter
  end
  object L3: TLabel
    Left = 16
    Top = 68
    Width = 66
    Height = 13
    Caption = 'Divide Factor:'
  end
  object L4: TLabel
    Left = 168
    Top = 68
    Width = 3
    Height = 13
  end
  object L5: TLabel
    Left = 16
    Top = 100
    Width = 32
    Height = 13
    Caption = 'X-shift:'
  end
  object L6: TLabel
    Left = 16
    Top = 124
    Width = 32
    Height = 13
    Caption = 'Y-shift:'
  end
  object OKButton: TButton
    Left = 138
    Top = 184
    Width = 73
    Height = 25
    Hint = 'Return to tile editor'
    Caption = '&Go'
    Default = True
    TabOrder = 4
    OnClick = OKButtonClick
  end
  object OpenButton: TButton
    Left = 10
    Top = 8
    Width = 73
    Height = 25
    Hint = 'Create a new palette'
    Caption = '&Open...'
    TabOrder = 0
    OnClick = OpenButtonClick
  end
  object FirstFrame: TSpinEdit
    Left = 128
    Top = 8
    Width = 57
    Height = 22
    Hint = 'Maximum number of colors'
    MaxValue = 9999
    MinValue = 0
    TabOrder = 1
    Value = 1
    OnChange = FirstFrameChange
  end
  object LastFrame: TSpinEdit
    Left = 232
    Top = 8
    Width = 57
    Height = 22
    Hint = 'Maximum number of colors'
    MaxValue = 9999
    MinValue = 0
    TabOrder = 2
    Value = 1
    OnChange = LastFrameChange
  end
  object CancelButton: TButton
    Left = 218
    Top = 184
    Width = 73
    Height = 25
    Hint = 'Create a new palette'
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = CancelButtonClick
  end
  object DivideFactor: TSpinEdit
    Left = 96
    Top = 64
    Width = 57
    Height = 22
    Hint = 'Maximum number of colors'
    MaxValue = 256
    MinValue = 1
    TabOrder = 3
    Value = 1
  end
  object XShift: TSpinEdit
    Left = 56
    Top = 96
    Width = 57
    Height = 22
    Hint = 'Maximum number of colors'
    MaxValue = 9999
    MinValue = -9999
    TabOrder = 6
    Value = 0
  end
  object YShift: TSpinEdit
    Left = 56
    Top = 120
    Width = 57
    Height = 22
    Hint = 'Maximum number of colors'
    MaxValue = 9999
    MinValue = -9999
    TabOrder = 7
    Value = 0
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp|All Files (*.*)|*.*'
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 104
    Top = 184
  end
end
