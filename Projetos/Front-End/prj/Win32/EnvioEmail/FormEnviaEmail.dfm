object FormEnvia: TFormEnvia
  Left = 0
  Top = 0
  Caption = 'FormEnvia'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object edtPara: TEdit
    Left = 8
    Top = 24
    Width = 321
    Height = 23
    TabOrder = 0
    Text = 'dtecnosistemas@gmail.com'
  end
  object mmMensagem: TMemo
    Left = 0
    Top = 64
    Width = 624
    Height = 377
    Align = alBottom
    Lines.Strings = (
      'Teste')
    TabOrder = 1
  end
  object btnEnviar: TButton
    Left = 335
    Top = 23
    Width = 75
    Height = 25
    Caption = 'Enviar Email'
    TabOrder = 2
    OnClick = btnEnviarClick
  end
end
