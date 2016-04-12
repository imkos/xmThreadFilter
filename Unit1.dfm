object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 375
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object edt1: TEdit
    Left = 8
    Top = 8
    Width = 329
    Height = 21
    TabOrder = 0
    OnChange = edt1Change
  end
  object lv1: TListView
    Left = 8
    Top = 35
    Width = 329
    Height = 332
    Columns = <
      item
        Width = 280
      end>
    OwnerData = True
    ReadOnly = True
    TabOrder = 1
    ViewStyle = vsReport
    OnData = lv1Data
  end
end
