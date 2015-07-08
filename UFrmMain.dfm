object FrmMain: TFrmMain
  Left = 210
  Top = 41
  Caption = 'FrmMain'
  ClientHeight = 753
  ClientWidth = 1004
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LPosition: TLabel
    Left = 760
    Top = 8
    Width = 43
    Height = 13
    Caption = 'LPosition'
  end
  object lblPriorities: TLabel
    Left = 760
    Top = 47
    Width = 49
    Height = 13
    Caption = 'lblPriorities'
  end
  object SG: TStringGrid
    Left = 0
    Top = 0
    Width = 754
    Height = 754
    TabOrder = 0
    OnDrawCell = SGDrawCell
    OnMouseUp = SGMouseUp
  end
  object SGAbil: TStringGrid
    Left = 760
    Top = 66
    Width = 240
    Height = 247
    ScrollBars = ssNone
    TabOrder = 1
    OnMouseUp = SGAbilMouseUp
  end
end
