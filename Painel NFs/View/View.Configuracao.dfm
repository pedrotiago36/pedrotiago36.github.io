object FrmConfiguracao: TFrmConfiguracao
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'NFSe '#8212' Configura'#231#227'o'
  ClientHeight = 684
  ClientWidth = 720
  Color = 15921906
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
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
      Width = 246
      Height = 30
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
      Width = 107
      Height = 15
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
    Top = 660
    Width = 720
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 15261872
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 628
    object lblStatus: TLabel
      Left = 12
      Top = 4
      Width = 39
      Height = 15
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
    Top = 620
    Width = 720
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 588
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
    Height = 548
    Align = alClient
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 3
    ExplicitHeight = 516
    object pnlWebService: TPanel
      Left = 16
      Top = 16
      Width = 688
      Height = 136
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblHomologacao: TLabel
        Left = 14
        Top = 48
        Width = 79
        Height = 15
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
        Top = 100
        Width = 54
        Height = 15
        Caption = 'Produ'#231#227'o:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object pnlWebServiceTopo: TPanel
        Left = 0
        Top = 0
        Width = 688
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = clSilver
        ParentBackground = False
        TabOrder = 0
        object lblGrpWebService: TLabel
          Left = 14
          Top = 8
          Width = 170
          Height = 17
          Caption = 'Endere'#231'os dos WebServices'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object rbHomologacao: TRadioButton
        Left = 96
        Top = 45
        Width = 20
        Height = 20
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbHomologacaoClick
      end
      object pnlBordaHomolog: TPanel
        Left = 119
        Top = 40
        Width = 558
        Height = 27
        BevelOuter = bvNone
        Color = 52224
        ParentBackground = False
        TabOrder = 2
        object edtUrlHomologacao: TEdit
          Left = 2
          Top = 2
          Width = 554
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          TextHint = 'https://homologacao.sefin.fortaleza.ce.gov.br/...'
        end
      end
      object rbProducao: TRadioButton
        Left = 96
        Top = 97
        Width = 20
        Height = 20
        TabOrder = 3
        OnClick = rbProducaoClick
      end
      object pnlBordaProducao: TPanel
        Left = 119
        Top = 92
        Width = 558
        Height = 27
        BevelOuter = bvNone
        Color = 52
        ParentBackground = False
        TabOrder = 4
        object edtUrlProducao: TEdit
          Left = 2
          Top = 2
          Width = 554
          Height = 23
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          TextHint = 'https://iss.fortaleza.ce.gov.br/...'
        end
      end
    end
    object pnlDiretorios: TPanel
      Left = 16
      Top = 168
      Width = 688
      Height = 180
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblDirEnviados: TLabel
        Left = 14
        Top = 44
        Width = 73
        Height = 15
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
        Width = 74
        Height = 15
        Caption = 'RPS com Erro:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirCancelados: TLabel
        Left = 14
        Top = 108
        Width = 87
        Height = 15
        Caption = 'RPS Cancelados:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblDirIni: TLabel
        Left = 14
        Top = 140
        Width = 64
        Height = 15
        Caption = 'Arquivo .ini:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
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
      object btnDirCancelados: TSpeedButton
        Left = 656
        Top = 104
        Width = 28
        Height = 24
        Caption = '...'
        Flat = True
        OnClick = btnDirCanceladosClick
      end
      object btnDirIni: TSpeedButton
        Left = 656
        Top = 136
        Width = 28
        Height = 24
        Caption = '...'
        Flat = True
        OnClick = btnDirIniClick
      end
      object pnlDiretoiriosTopo: TPanel
        Left = 0
        Top = 0
        Width = 688
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 13303807
        ParentBackground = False
        TabOrder = 0
        object lblGrpDiretorios: TLabel
          Left = 14
          Top = 8
          Width = 186
          Height = 17
          Caption = 'Diret'#243'rios de Armazenamento'
          Color = -1
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1977147
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentColor = False
          ParentFont = False
        end
      end
      object edtDirEnviados: TEdit
        Left = 120
        Top = 40
        Width = 532
        Height = 23
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
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        TextHint = 'Ex: C:\NFSe\Erros'
      end
      object edtDirCancelados: TEdit
        Left = 120
        Top = 104
        Width = 532
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        TextHint = 'Ex: C:\NFSe\Cancelados'
      end
      object edtDirIni: TEdit
        Left = 120
        Top = 136
        Width = 532
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        TextHint = 'Ex: C:\NFSe\Config'
      end
    end
    object pnlModoEnvio: TPanel
      Left = 16
      Top = 364
      Width = 336
      Height = 120
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblDataEnvio: TLabel
        Left = 16
        Top = 73
        Width = 75
        Height = 15
        Caption = 'Data de Envio:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object pnlModoEnvioTopo: TPanel
        Left = 0
        Top = 0
        Width = 336
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        Color = 4227200
        ParentBackground = False
        TabOrder = 0
        object lblGrpModoEnvio: TLabel
          Left = 14
          Top = 8
          Width = 93
          Height = 17
          Caption = 'Modo de Envio'
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentColor = False
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
      object edtDataEnvio: TEdit
        Left = 172
        Top = 69
        Width = 55
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
    end
    object pnlThread: TPanel
      Left = 368
      Top = 364
      Width = 336
      Height = 120
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
        Color = clMaroon
        ParentBackground = False
        TabOrder = 0
        object lblGrpThread: TLabel
          Left = 14
          Top = 8
          Width = 119
          Height = 17
          Caption = 'Controle de Thread'
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentColor = False
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
      Top = 460
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
