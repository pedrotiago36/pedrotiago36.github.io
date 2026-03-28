object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'DT&&LL Transportadoras'
  ClientHeight = 700
  ClientWidth = 1280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = UniFormCreate
  object UniHTMLFrame1: TUniHTMLFrame
    Left = 0
    Top = 0
    Width = 1280
    Height = 700
    Align = alClient
    OnAjaxEvent = HtmlFrameAjaxEvent
  end
end
