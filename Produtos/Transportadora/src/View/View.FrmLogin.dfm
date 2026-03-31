object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  ClientHeight = 768
  ClientWidth = 1366
  Caption = 'DT&&LL Transportadoras'
  BorderStyle = bsNone
  OldCreateOrder = False
  BorderIcons = []
  MonitoredKeys.Keys = <>
  OnCreate = UniFormCreate
  TextHeight = 15
  object HtmlLogin: TUniURLFrame
    Left = 0
    Top = 0
    Width = 1366
    Height = 768
    Hint = ''
    Align = alClient
    TabOrder = 0
    ParentColor = False
    Color = clBtnFace
    OnAjaxEvent = HtmlLoginAjaxEvent
  end
  object HtmlMain: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 1366
    Height = 768
    Hint = ''
    Visible = False
    Align = alClient
    OnAjaxEvent = HtmlMainAjaxEvent
  end
end
