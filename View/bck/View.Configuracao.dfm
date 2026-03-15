object FrmConfiguracao: TFrmConfiguracao
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'NFSe '#8212' Configura'#231#227'o'
  ClientHeight = 620
  ClientWidth = 720
  Color = 15921906
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 16
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    Color = 1977147
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 10
      Width = 300
      Height = 28
      Caption = 'Configura'#231#227'o do Sistema'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblVersao: TLabel
      Left = 22
      Top = 44
      Width = 200
      Height = 16
      Caption = 'NFSe Emissor  '#183'  v1.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 7107965
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 596
    Width = 720
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 15261872
    ParentBackground = False
    TabOrder = 1
    object lblStatus: TLabel
      Left = 12
      Top = 4
      Width = 60
      Height = 16
      Caption = 'Pronto.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 7368816
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 556
    Width = 720
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 2
    object btnSalvar: TBitBtn
      Left = 504
      Top = 6
      Width = 100
      Height = 30
      Caption = '  Salvar'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TBitBtn
      Left = 610
      Top = 6
      Width = 100
      Height = 30
      Caption = '  Fechar'
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object pnlConteudo: TPanel
    Left = 0
    Top = 72
    Width = 720
    Height = 484
    Align = alClient
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 3
    object pnlWebService: TPanel
      Left = 16
      Top = 16
      Width = 688
      Height = 104
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object pnlWebServiceTopo: TPanel
        Left = 0
        Top = 0
        Width = 688
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 14737479
        ParentBackground = False
        TabOrder = 0
        object lblGrpWebService: TLabel
          Left = 14
          Top = 8
          Width = 200
          Height = 16
          Caption = '#9881  Endere'#231'os dos WebServices'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object lblHomologacao: TLabel
        Left = 14
        Top = 44
        Width = 96
        Height = 16
        Caption = 'Homologa'#231#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblProducao: TLabel
        Left = 14
        Top = 76
        Width = 60
        Height = 16
        Caption = 'Produ'#231#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtUrlHomologacao: TEdit
        Left = 120
        Top = 40
        Width = 554
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TextHint = 'https://homologacao.sefin.fortaleza.ce.gov.br/...'
      end
      object edtUrlProducao: TEdit
        Left = 120
        Top = 72
        Width = 554
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        TextHint = 'https://iss.fortaleza.ce.gov.br/...'
      end
    end
    object pnlDiretorios: TPanel
      Left = 16
      Top = 136
      Width = 688
      Height = 148
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object pnlDiretoiriosTopo: TPanel
        Left = 0
        Top = 0
        Width = 688
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 14737479
        ParentBackground = False
        TabOrder = 0
        object lblGrpDiretorios: TLabel
          Left = 14
          Top = 8
          Width = 220
          Height = 16
          Caption = '#128193  Diret'#243'rios de Armazenamento'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object lblDirEnviados: TLabel
        Left = 14
        Top = 44
        Width = 82
        Height = 16
        Caption = 'RPS Enviados:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirErro: TLabel
        Left = 14
        Top = 76
        Width = 80
        Height = 16
        Caption = 'RPS com Erro:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirIni: TLabel
        Left = 14
        Top = 108
        Width = 68
        Height = 16
        Caption = 'Arquivo .ini:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtDirEnviados: TEdit
        Left = 120
        Top = 40
        Width = 532
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        TextHint = 'Ex: C:\NFSe\Enviados'
      end
      object edtDirErro: TEdit
        Left = 120
        Top = 72
        Width = 532
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        TextHint = 'Ex: C:\NFSe\Erros'
      end
      object edtDirIni: TEdit
        Left = 120
        Top = 104
        Width = 532
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        TextHint = 'Ex: C:\NFSe\Config'
      end
      object btnDirEnviados: TSpeedButton
        Left = 656
        Top = 40
        Width = 28
        Height = 24
        Caption = '...'
        Flat = True
        OnClick = btnDirEnviadosClick
      end
      object btnDirErro: TSpeedButton
        Left = 656
        Top = 72
        Width = 28
        Height = 24
        Caption = '...'
        Flat = True
        OnClick = btnDirErroClick
      end
      object btnDirIni: TSpeedButton
        Left = 656
        Top = 104
        Width = 28
        Height = 24
        Caption = '...'
        Flat = True
        OnClick = btnDirIniClick
      end
    end
    object pnlModoEnvio: TPanel
      Left = 16
      Top = 300
      Width = 336
      Height = 80
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object pnlModoEnvioTopo: TPanel
        Left = 0
        Top = 0
        Width = 336
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 14737479
        ParentBackground = False
        TabOrder = 0
        object lblGrpModoEnvio: TLabel
          Left = 14
          Top = 8
          Width = 120
          Height = 16
          Caption = '#128228  Modo de Envio'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object rbEnviarLote: TRadioButton
        Left = 16
        Top = 40
        Width = 148
        Height = 24
        Caption = '  Enviar em Lote'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1977147
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        TabStop = True
      end
      object rbEnviarIndividual: TRadioButton
        Left = 172
        Top = 40
        Width = 148
        Height = 24
        Caption = '  Individual'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
    end
    object pnlThread: TPanel
      Left = 368
      Top = 300
      Width = 336
      Height = 80
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object pnlThreadTopo: TPanel
        Left = 0
        Top = 0
        Width = 336
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 14737479
        ParentBackground = False
        TabOrder = 0
        object lblGrpThread: TLabel
          Left = 14
          Top = 8
          Width = 160
          Height = 16
          Caption = '#9881  Controle de Thread'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object chbLigDesl_Thread: TCheckBox
        Left = 16
        Top = 40
        Width = 300
        Height = 28
        Caption = '  '#9675' Thread Desligada'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = chbLigDesl_ThreadClick
      end
    end
    object pnlSeparador: TPanel
      Left = 16
      Top = 396
      Width = 688
      Height = 1
      BevelOuter = bvNone
      Color = 14211288
      ParentBackground = False
      TabOrder = 4
    end
  end
  object grpWebService: TGroupBox
    Left = 0
    Top = 0
    Width = 0
    Height = 0
    Caption = 'hidden'
    TabOrder = 4
    Visible = False
  end
  object grpDiretorios: TGroupBox
    Left = 0
    Top = 0
    Width = 0
    Height = 0
    Caption = 'hidden'
    TabOrder = 5
    Visible = False
  end
  object grpThread: TGroupBox
    Left = 0
    Top = 0
    Width = 0
    Height = 0
    Caption = 'hidden'
    TabOrder = 6
    Visible = False
  end
end
