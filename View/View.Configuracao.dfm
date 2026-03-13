object FrmConfiguracao: TFrmConfiguracao
  Left = 0
  Top = 0
  Caption = 'NFSe Serv'#231'o '#8212' Configura'#231#227'o'
  ClientHeight = 482
  ClientWidth = 680
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 680
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = 11556896
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 8
      Top = 8
      Width = 275
      Height = 23
      Caption = '  NFSe '#8212' Configura'#231#227'o do Servi'#231'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblVersao: TLabel
      Left = 8
      Top = 38
      Width = 35
      Height = 13
      Caption = '  v1.0.0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16769216
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
  end
  object pnlConteudo: TPanel
    Left = 0
    Top = 56
    Width = 680
    Height = 378
    Align = alClient
    BevelOuter = bvNone
    Color = clWhitesmoke
    TabOrder = 1
    ExplicitHeight = 456
    object grpWebService: TGroupBox
      Left = 16
      Top = 16
      Width = 648
      Height = 100
      Caption = ' Endere'#231'os dos WebServices '
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      object lblHomologacao: TLabel
        Left = 12
        Top = 24
        Width = 103
        Height = 15
        Caption = 'URL Homologa'#231#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblProducao: TLabel
        Left = 12
        Top = 60
        Width = 78
        Height = 15
        Caption = 'URL Produ'#231#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtUrlHomologacao: TEdit
        Left = 128
        Top = 20
        Width = 504
        Height = 23
        TabOrder = 0
        TextHint = 'https://homologacao.sefin.fortaleza.ce.gov.br/...'
      end
      object edtUrlProducao: TEdit
        Left = 128
        Top = 56
        Width = 504
        Height = 23
        TabOrder = 1
        TextHint = 'https://iss.fortaleza.ce.gov.br/...'
      end
    end
    object grpDiretorios: TGroupBox
      Left = 16
      Top = 132
      Width = 648
      Height = 148
      Caption = ' Diret'#243'rios de Armazenamento '
      Color = clWhite
      ParentColor = False
      TabOrder = 1
      object lblDirEnviados: TLabel
        Left = 12
        Top = 24
        Width = 73
        Height = 15
        Caption = 'RPS Enviados:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirErro: TLabel
        Left = 12
        Top = 60
        Width = 74
        Height = 15
        Caption = 'RPS com Erro:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirIni: TLabel
        Left = 12
        Top = 96
        Width = 64
        Height = 15
        Caption = 'Arquivo .ini:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object btnDirEnviados: TSpeedButton
        Left = 608
        Top = 20
        Width = 28
        Height = 23
        Caption = '...'
        Flat = True
        OnClick = btnDirEnviadosClick
      end
      object btnDirErro: TSpeedButton
        Left = 608
        Top = 56
        Width = 28
        Height = 23
        Caption = '...'
        Flat = True
        OnClick = btnDirErroClick
      end
      object btnDirIni: TSpeedButton
        Left = 608
        Top = 92
        Width = 28
        Height = 23
        Caption = '...'
        Flat = True
        OnClick = btnDirIniClick
      end
      object edtDirEnviados: TEdit
        Left = 128
        Top = 20
        Width = 476
        Height = 23
        TabOrder = 0
        TextHint = 'Ex: C:\NFSe\Enviados'
      end
      object edtDirErro: TEdit
        Left = 128
        Top = 56
        Width = 476
        Height = 23
        TabOrder = 1
        TextHint = 'Ex: C:\NFSe\Erros'
      end
      object edtDirIni: TEdit
        Left = 128
        Top = 92
        Width = 476
        Height = 23
        TabOrder = 2
        TextHint = 'Ex: C:\NFSe\Config'
      end
    end
    object grpThread: TGroupBox
      Left = 16
      Top = 296
      Width = 648
      Height = 68
      Caption = ' Controle de Thread '
      Color = clWhite
      ParentColor = False
      TabOrder = 2
      object chbLigDesl_Thread: TCheckBox
        Left = 16
        Top = 24
        Width = 280
        Height = 28
        Caption = '  '#9675' Thread Desligada'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = chbLigDesl_ThreadClick
      end
    end
  end
  object pnlStatusBar: TPanel
    Left = 0
    Top = 434
    Width = 680
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 14737632
    TabOrder = 2
    ExplicitTop = 512
    object lblStatus: TLabel
      Left = 4
      Top = 4
      Width = 44
      Height = 13
      Caption = '  Pronto.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 30464
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Transparent = True
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 458
    Width = 680
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 15263976
    TabOrder = 3
    ExplicitTop = 536
    object btnSalvar: TBitBtn
      Left = 480
      Top = 2
      Width = 96
      Height = 28
      Caption = '  Salvar'
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TBitBtn
      Left = 580
      Top = 2
      Width = 88
      Height = 28
      Caption = '  Fechar'
      Kind = bkClose
      NumGlyphs = 2
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
end
