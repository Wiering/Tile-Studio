object RGBConv: TRGBConv
  Left = 192
  Top = 107
  Width = 545
  Height = 497
  Anchors = [akLeft, akBottom]
  Caption = 'Color Conversion Scripts'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblFilename: TLabel
    Left = 8
    Top = 428
    Width = 39
    Height = 18
    Anchors = [akLeft, akBottom]
    Caption = 'filename'
  end
  object Script: TMemo
    Left = 8
    Top = 8
    Width = 513
    Height = 405
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object btnSave: TButton
    Left = 335
    Top = 424
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Save'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 431
    Top = 424
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
