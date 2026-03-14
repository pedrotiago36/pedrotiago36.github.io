object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'NFSe - Monitor de Envio'
  ClientHeight = 768
  ClientWidth = 1280
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mnuPrincipal
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 52
    Align = alTop
    BevelOuter = bvNone
    Color = 11556896
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 8
      Top = 8
      Width = 267
      Height = 23
      Caption = '  NFSe - Monitor de Envio de RPS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMesAno: TLabel
      Left = 8
      Top = 36
      Width = 71
      Height = 13
      Caption = '  Janeiro/2026'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 16769216
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object btnAtualizar: TSpeedButton
      Left = 1190
      Top = 10
      Width = 84
      Height = 32
      Caption = '  Atualizar'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnAtualizarClick
    end
    object pnlModoEnvio: TPanel
      Left = 600
      Top = 0
      Width = 480
      Height = 52
      BevelOuter = bvNone
      Color = 9849626
      TabOrder = 0
      object rbEnviarLote: TRadioButton
        Left = 8
        Top = 14
        Width = 170
        Height = 20
        Caption = '  Enviar em Lote'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        TabStop = True
      end
      object rbEnviarIndividual: TRadioButton
        Left = 190
        Top = 14
        Width = 270
        Height = 20
        Caption = '  Enviar RPS de forma individual'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
    end
  end
  object pnlCards: TPanel
    Left = 0
    Top = 52
    Width = 1280
    Height = 110
    Align = alTop
    BevelOuter = bvNone
    Color = 15790837
    TabOrder = 1
    object pnlCardSede: TPanel
      Left = 8
      Top = 8
      Width = 298
      Height = 94
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 0
      object lblCardNomeSede: TLabel
        Left = 12
        Top = 8
        Width = 31
        Height = 17
        Caption = 'SEDE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11556896
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvSede: TLabel
        Left = 12
        Top = 38
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvSede: TLabel
        Left = 66
        Top = 28
        Width = 16
        Height = 37
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvSedeClick
      end
      object lblCardCancSede: TLabel
        Left = 140
        Top = 38
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancSede: TLabel
        Left = 210
        Top = 32
        Width = 10
        Height = 23
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12986408
        Font.Height = -17
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancSedeClick
      end
    end
    object pnlCardUEQ: TPanel
      Left = 318
      Top = 8
      Width = 298
      Height = 94
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 1
      object lblCardNomeUEQ: TLabel
        Left = 12
        Top = 8
        Width = 26
        Height = 17
        Caption = 'UEQ'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11556896
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvUEQ: TLabel
        Left = 12
        Top = 38
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvUEQ: TLabel
        Left = 66
        Top = 28
        Width = 16
        Height = 37
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvUEQClick
      end
      object lblCardCancUEQ: TLabel
        Left = 140
        Top = 38
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancUEQ: TLabel
        Left = 210
        Top = 32
        Width = 10
        Height = 23
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12986408
        Font.Height = -17
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancUEQClick
      end
    end
    object pnlCardVarjota: TPanel
      Left = 628
      Top = 8
      Width = 298
      Height = 94
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 2
      object lblCardNomeVarjota: TLabel
        Left = 12
        Top = 8
        Width = 44
        Height = 17
        Caption = 'Varjota'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11556896
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvVarjota: TLabel
        Left = 12
        Top = 38
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvVarjota: TLabel
        Left = 66
        Top = 28
        Width = 16
        Height = 37
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvVarjotaClick
      end
      object lblCardCancVarjota: TLabel
        Left = 140
        Top = 38
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancVarjota: TLabel
        Left = 210
        Top = 32
        Width = 10
        Height = 23
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12986408
        Font.Height = -17
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancVarjotaClick
      end
    end
    object pnlCardSeisBocas: TPanel
      Left = 938
      Top = 8
      Width = 298
      Height = 94
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 3
      object lblCardNomeSeisBocas: TLabel
        Left = 12
        Top = 8
        Width = 63
        Height = 17
        Caption = 'Seis Bocas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11556896
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvSeisBocas: TLabel
        Left = 12
        Top = 38
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvSeisBocas: TLabel
        Left = 66
        Top = 28
        Width = 16
        Height = 37
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 3046706
        Font.Height = -27
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvSeisBocasClick
      end
      object lblCardCancSeisBocas: TLabel
        Left = 140
        Top = 38
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancSeisBocas: TLabel
        Left = 210
        Top = 32
        Width = 10
        Height = 23
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 12986408
        Font.Height = -17
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancSeisBocasClick
      end
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 744
    Width = 1280
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 14737632
    TabOrder = 2
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
    end
  end
  object pgcUnidades: TPageControl
    Left = 0
    Top = 162
    Width = 1280
    Height = 582
    ActivePage = tabSede
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    object tabSede: TTabSheet
      Caption = '  SEDE  '
      object pgcTipoSede: TPageControl
        Left = 0
        Top = 0
        Width = 1272
        Height = 552
        ActivePage = tabLoteSede
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object tabLoteSede: TTabSheet
          Caption = '  RPS Lotes  '
          object pgcSitLoteSede: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvLoteSede
            Align = alClient
            TabOrder = 0
            object tabEnvLoteSede: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteSede: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 492
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancLoteSede: TTabSheet
              Caption = '  Canceladas  '
              object grdCancLoteSede: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
          end
        end
        object tabIndividualSede: TTabSheet
          Caption = '  RPS Individual  '
          object pgcSitIndivSede: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvIndivSede
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvIndivSede: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivSede: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancIndivSede: TTabSheet
              Caption = '  Canceladas  '
            end
          end
        end
      end
    end
    object tabUEQ: TTabSheet
      Caption = '  UEQ  '
      object pgcTipoUEQ: TPageControl
        Left = 0
        Top = 0
        Width = 1272
        Height = 552
        ActivePage = tabLoteUEQ
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 554
        object tabLoteUEQ: TTabSheet
          Caption = '  RPS Lotes  '
          object pgcSitLoteUEQ: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvLoteUEQ
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvLoteUEQ: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteUEQ: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancLoteUEQ: TTabSheet
              Caption = '  Canceladas  '
              object grdCancLoteUEQ: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
          end
        end
        object tabIndividualUEQ: TTabSheet
          Caption = '  RPS Individual  '
          object pgcSitIndivUEQ: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvIndivUEQ
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvIndivUEQ: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivUEQ: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancIndivUEQ: TTabSheet
              Caption = '  Canceladas  '
            end
          end
        end
      end
    end
    object tabVarjota: TTabSheet
      Caption = '  Varjota  '
      object pgcTipoVarjota: TPageControl
        Left = 0
        Top = 0
        Width = 1272
        Height = 552
        ActivePage = tabLoteVarjota
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 554
        object tabLoteVarjota: TTabSheet
          Caption = '  RPS Lotes  '
          object pgcSitLoteVarjota: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvLoteVarjota
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvLoteVarjota: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteVarjota: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancLoteVarjota: TTabSheet
              Caption = '  Canceladas  '
              object grdCancLoteVarjota: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
          end
        end
        object tabIndividualVarjota: TTabSheet
          Caption = '  RPS Individual  '
          object pgcSitIndivVarjota: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvIndivVarjota
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvIndivVarjota: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivVarjota: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancIndivVarjota: TTabSheet
              Caption = '  Canceladas  '
            end
          end
        end
      end
    end
    object tabSeisBocas: TTabSheet
      Caption = '  Seis Bocas  '
      object pgcTipoSeisBocas: TPageControl
        Left = 0
        Top = 0
        Width = 1272
        Height = 552
        ActivePage = tabLoteSeisBocas
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 554
        object tabLoteSeisBocas: TTabSheet
          Caption = '  RPS Lotes  '
          object pgcSitLoteSeisBocas: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvLoteSeisBocas
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvLoteSeisBocas: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteSeisBocas: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancLoteSeisBocas: TTabSheet
              Caption = '  Canceladas  '
              object grdCancLoteSeisBocas: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
          end
        end
        object tabIndividualSeisBocas: TTabSheet
          Caption = '  RPS Individual  '
          object pgcSitIndivSeisBocas: TPageControl
            Left = 0
            Top = 0
            Width = 1264
            Height = 522
            ActivePage = tabEnvIndivSeisBocas
            Align = alClient
            TabOrder = 0
            ExplicitHeight = 526
            object tabEnvIndivSeisBocas: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivSeisBocas: TDBGridEh
                Left = 0
                Top = 0
                Width = 1256
                Height = 498
                Align = alClient
                DynProps = <>
                TabOrder = 0
                object RowDetailData: TRowDetailPanelControlEh
                end
              end
            end
            object tabCancIndivSeisBocas: TTabSheet
              Caption = '  Canceladas  '
            end
          end
        end
      end
    end
  end
  object mnuPrincipal: TMainMenu
    object mnuSistema: TMenuItem
      Caption = '&Sistema'
      object mnuConfiguracoes: TMenuItem
        Caption = '&Configuracoes'
        OnClick = mnuConfiguracoesClick
      end
      object mnuSeparador1: TMenuItem
        Caption = '-'
      end
      object mnuSair: TMenuItem
        Caption = 'Sair'
        OnClick = mnuSairClick
      end
    end
    object mnuFerramentas: TMenuItem
      Caption = '&Ferramentas'
      object mnuAtualizar: TMenuItem
        Caption = '&Atualizar Dados'
        OnClick = mnuAtualizarClick
      end
    end
  end
  object mtEnvLoteSede: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtCancLoteSede: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvIndivSede: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvLoteUEQ: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtCancLoteUEQ: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvIndivUEQ: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvLoteVarjota: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtCancLoteVarjota: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvIndivVarjota: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvLoteSeisBocas: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtCancLoteSeisBocas: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object mtEnvIndivSeisBocas: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
  end
  object dsEnvLoteSede: TDataSource
  end
  object dsCancLoteSede: TDataSource
  end
  object dsEnvIndivSede: TDataSource
  end
  object dsEnvLoteUEQ: TDataSource
  end
  object dsCancLoteUEQ: TDataSource
  end
  object dsEnvIndivUEQ: TDataSource
  end
  object dsEnvLoteVarjota: TDataSource
  end
  object dsCancLoteVarjota: TDataSource
  end
  object dsEnvIndivVarjota: TDataSource
  end
  object dsEnvLoteSeisBocas: TDataSource
  end
  object dsCancLoteSeisBocas: TDataSource
  end
  object dsEnvIndivSeisBocas: TDataSource
  end
end
