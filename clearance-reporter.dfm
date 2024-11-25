object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Clearance Reporter'
  ClientHeight = 703
  ClientWidth = 1194
  Color = 4210752
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 19
  object Label1: TLabel
    Left = 12
    Top = 25
    Width = 97
    Height = 19
    Caption = 'Net Selector 1'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Font.Quality = fqProof
    ParentFont = False
  end
  object Label2: TLabel
    Left = 230
    Top = 25
    Width = 97
    Height = 19
    Caption = 'Net Selector 2'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Font.Quality = fqProof
    ParentFont = False
  end
  object XPProgressBar1: TXPProgressBar
    Left = 12
    Top = 680
    Width = 1176
    Height = 16
    Position = 0
    Smooth = True
    Step = 0
    TabOrder = 0
  end
  object Memo3: TMemo
    Left = 12
    Top = 375
    Width = 1176
    Height = 300
    Cursor = crHandPoint
    Color = 3881787
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = False
  end
  object btnClose: TButton
    Left = 1080
    Top = 16
    Width = 88
    Height = 26
    Caption = 'Close'
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object lbClasses1: TXPListBox
    Left = 12
    Top = 50
    Width = 200
    Height = 320
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = 8453888
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = []
    Font.Quality = fqProof
    ParentFont = False
    Sorted = True
    TabOrder = 3
  end
  object lbClasses2: TXPListBox
    Left = 230
    Top = 50
    Width = 200
    Height = 320
    Cursor = crHandPoint
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = 8453888
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = []
    Font.Quality = fqProof
    ParentFont = False
    Sorted = True
    TabOrder = 4
  end
  object lbElements: TXPListBox
    Left = 438
    Top = 50
    Width = 106
    Height = 150
    Cursor = crHandPoint
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = 12615680
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Font.Quality = fqProof
    Items.Strings = (
      'Arc'
      'Fill'
      'Pad'
      'Poly'
      'Track'
      'Via')
    MultiSelect = True
    ParentFont = False
    ScrollBars = pssNone
    TabOrder = 5
    UseCheckBoxes = True
  end
  object lbLayers: TXPListBox
    Left = 550
    Top = 50
    Width = 106
    Height = 150
    Cursor = crHandPoint
    Color = clSilver
    Font.Charset = ANSI_CHARSET
    Font.Color = 12615680
    Font.Height = -16
    Font.Name = 'Calibri'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Font.Quality = fqProof
    Items.Strings = (
      'Top'
      'Mid1'
      'Mid2'
      'Bottom')
    MultiSelect = True
    ParentFont = False
    ScrollBars = pssNone
    TabOrder = 6
    UseCheckBoxes = True
  end
  object XPButtonEx1: TXPButtonEx
    Left = 840
    Top = 16
    Width = 0
    Height = 0
    Caption = 'XPButtonEx1'
    ParentColor = False
    TabOrder = 7
    TabStop = False
  end
  object XPButtonEx2: TXPButtonEx
    Left = 880
    Top = 24
    Width = 0
    Height = 0
    Caption = 'XPButtonEx2'
    ParentColor = False
    TabOrder = 8
    TabStop = False
  end
  object XPButtonEx3: TXPButtonEx
    Left = 944
    Top = 224
    Width = 0
    Height = 0
    Caption = 'XPButtonEx3'
    ParentColor = False
    TabOrder = 9
    TabStop = False
  end
  object XPButtonEx4: TXPButtonEx
    Left = 912
    Top = 296
    Width = 272
    Height = 64
    Caption = 'Start'
    ParentColor = False
    TabOrder = 10
    TabStop = False
    OnClick = XPButtonEx4Click
  end
end
