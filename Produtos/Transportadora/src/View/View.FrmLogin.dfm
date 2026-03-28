object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  ClientHeight = 768
  ClientWidth = 1366
  Caption = 'DT&&LL Transporte'
  BorderStyle = bsNone
  OldCreateOrder = False
  BorderIcons = []
  MonitoredKeys.Keys = <>
  TextHeight = 15
  OnCreate = UniFormCreate
  object HtmlLogin: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 1366
    Height = 768
    Align = alClient
    HTML.Strings = ()
    OnAjaxEvent = HtmlLoginAjaxEvent
  end
end
