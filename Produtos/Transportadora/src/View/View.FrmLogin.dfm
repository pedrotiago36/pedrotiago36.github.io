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
  TextHeight = 15
  OnCreate = UniFormCreate
  object HtmlLogin: TUniURLFrame
    Left = 0
    Top = 0
    Width = 1366
    Height = 768
    Align = alClient
    HTML.Strings = ()
    OnAjaxEvent = HtmlLoginAjaxEvent
  end
  object HtmlMain: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 1366
    Height = 768
    Align = alClient
    Visible = False
    HTML.Strings = ()
    OnAjaxEvent = HtmlMainAjaxEvent
  end
end
