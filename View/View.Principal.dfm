object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'NFSe'
  ClientHeight = 900
  ClientWidth = 1440
  Color = 15659775
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 17
  object pnlSidebar: TPanel
    Left = 0
    Top = 200
    Width = 220
    Height = 676
    Align = alLeft
    BevelOuter = bvNone
    Color = 3359061
    ParentBackground = False
    TabOrder = 4
    object pnlSidebarTopo: TPanel
      Left = 0
      Top = 0
      Width = 220
      Height = 80
      Align = alTop
      BevelOuter = bvNone
      Color = 1977147
      ParentBackground = False
      TabOrder = 0
      object lblSideLogo: TLabel
        Left = 0
        Top = 0
        Width = 220
        Height = 80
        Alignment = taCenter
        AutoSize = False
        Caption = 'NF'#183'Se'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -33
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
      end
    end
    object pnlSidebarMenu: TPanel
      Left = 0
      Top = 80
      Width = 220
      Height = 536
      Align = alClient
      BevelOuter = bvNone
      Color = 3359061
      ParentBackground = False
      TabOrder = 1
      object lblMenuSecao1: TLabel
        Left = 16
        Top = 20
        Width = 68
        Height = 13
        Caption = 'NAVEGA'#199#195'O'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579300
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblMenuSede: TLabel
        Left = 0
        Top = 44
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#9632'  SEDE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlCenter
        OnClick = lblCardQtdEnvSedeClick
      end
      object lblMenuUEQ: TLabel
        Left = 0
        Top = 88
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#9633'  UEQ'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10066329
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblCardQtdEnvUEQClick
      end
      object lblMenuVarjota: TLabel
        Left = 0
        Top = 132
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#9633'  Varjota'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10066329
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblCardQtdEnvVarjotaClick
      end
      object lblMenuSeisBocas: TLabel
        Left = 0
        Top = 176
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#9633'  Seis Bocas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10066329
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblCardQtdEnvSeisBocasClick
      end
      object lblMenuSecao2: TLabel
        Left = 16
        Top = 240
        Width = 46
        Height = 13
        Caption = 'SISTEMA'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579300
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblMenuConfig: TLabel
        Left = 0
        Top = 264
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#9881'  Configura'#231#245'es'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 10066329
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblMenuConfigClick
      end
      object lblMenuSair: TLabel
        Left = 0
        Top = 308
        Width = 220
        Height = 40
        Cursor = crHandPoint
        AutoSize = False
        Caption = '    '#10006'  Sair'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 7039848
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblMenuSairClick
      end
    end
    object pnlSidebarRodape: TPanel
      Left = 0
      Top = 616
      Width = 220
      Height = 60
      Align = alBottom
      BevelOuter = bvNone
      Color = 1977147
      ParentBackground = False
      TabOrder = 2
      object lblSideRodape: TLabel
        Left = 0
        Top = 0
        Width = 220
        Height = 60
        Alignment = taCenter
        AutoSize = False
        Caption = 'v1.0  '#183'  NFSe Emissor'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6579300
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
    end
  end
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 1440
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    DesignSize = (
      1440
      60)
    object lblTitulo: TLabel
      Left = 20
      Top = 8
      Width = 259
      Height = 28
      Caption = 'Monitor de Emiss'#227'o de RPS'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3552822
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblMesAno: TLabel
      Left = 22
      Top = 38
      Width = 115
      Height = 15
      Caption = 'Carregando per'#237'odo...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8026746
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object btnAtualizar: TSpeedButton
      Left = 1316
      Top = 12
      Width = 112
      Height = 36
      Anchors = [akTop, akRight]
      Caption = #8635'  Atualizar'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnAtualizarClick
    end
  end
  object pnlCards: TPanel
    Left = 0
    Top = 60
    Width = 1440
    Height = 140
    Align = alTop
    BevelOuter = bvNone
    Color = 16448252
    ParentBackground = False
    TabOrder = 1
    object pnlCardSede: TPanel
      Left = 30
      Top = 12
      Width = 278
      Height = 116
      BevelOuter = bvNone
      Color = 8491256
      ParentBackground = False
      TabOrder = 0
      object lblCardNomeSede: TLabel
        Left = 16
        Top = 12
        Width = 246
        Height = 20
        AutoSize = False
        Caption = 'SEDE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvSede: TLabel
        Left = 16
        Top = 48
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15132390
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvSede: TLabel
        Left = 100
        Top = 30
        Width = 23
        Height = 54
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -40
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvSedeClick
      end
      object lblCardCancSede: TLabel
        Left = 16
        Top = 84
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15132390
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancSede: TLabel
        Left = 200
        Top = 76
        Width = 13
        Height = 30
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16777164
        Font.Height = -22
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancSedeClick
      end
    end
    object pnlCardUEQ: TPanel
      Left = 324
      Top = 12
      Width = 278
      Height = 116
      BevelOuter = bvNone
      Color = 3718648
      ParentBackground = False
      TabOrder = 1
      object lblCardNomeUEQ: TLabel
        Left = 16
        Top = 12
        Width = 246
        Height = 20
        AutoSize = False
        Caption = 'UEQ'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvUEQ: TLabel
        Left = 16
        Top = 48
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11993343
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvUEQ: TLabel
        Left = 100
        Top = 30
        Width = 23
        Height = 54
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -40
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvUEQClick
      end
      object lblCardCancUEQ: TLabel
        Left = 16
        Top = 84
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11993343
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancUEQ: TLabel
        Left = 200
        Top = 76
        Width = 13
        Height = 30
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16777164
        Font.Height = -22
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancUEQClick
      end
    end
    object pnlCardVarjota: TPanel
      Left = 618
      Top = 12
      Width = 278
      Height = 116
      BevelOuter = bvNone
      Color = 3461017
      ParentBackground = False
      TabOrder = 2
      object lblCardNomeVarjota: TLabel
        Left = 16
        Top = 12
        Width = 246
        Height = 20
        AutoSize = False
        Caption = 'Varjota'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvVarjota: TLabel
        Left = 16
        Top = 48
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13684944
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvVarjota: TLabel
        Left = 100
        Top = 30
        Width = 23
        Height = 54
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -40
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvVarjotaClick
      end
      object lblCardCancVarjota: TLabel
        Left = 16
        Top = 84
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 13684944
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancVarjota: TLabel
        Left = 200
        Top = 76
        Width = 13
        Height = 30
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16777164
        Font.Height = -22
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancVarjotaClick
      end
    end
    object pnlCardSeisBocas: TPanel
      Left = 912
      Top = 12
      Width = 278
      Height = 116
      BevelOuter = bvNone
      Color = 16498468
      ParentBackground = False
      TabOrder = 3
      object lblCardNomeSeisBocas: TLabel
        Left = 16
        Top = 12
        Width = 246
        Height = 20
        AutoSize = False
        Caption = 'Seis Bocas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -14
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardEnvSeisBocas: TLabel
        Left = 16
        Top = 48
        Width = 45
        Height = 13
        Caption = 'Enviadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14737632
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdEnvSeisBocas: TLabel
        Left = 100
        Top = 30
        Width = 23
        Height = 54
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -40
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdEnvSeisBocasClick
      end
      object lblCardCancSeisBocas: TLabel
        Left = 16
        Top = 84
        Width = 58
        Height = 13
        Caption = 'Canceladas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 14737632
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardQtdCancSeisBocas: TLabel
        Left = 200
        Top = 76
        Width = 13
        Height = 30
        Cursor = crHandPoint
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 16777164
        Font.Height = -22
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = lblCardQtdCancSeisBocasClick
      end
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 876
    Width = 1440
    Height = 24
    Align = alBottom
    BevelOuter = bvNone
    Color = 15792633
    ParentBackground = False
    TabOrder = 2
    object lblStatus: TLabel
      Left = 12
      Top = 4
      Width = 39
      Height = 15
      Caption = 'Pronto.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 8026746
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pgcUnidades: TPageControl
    Left = 220
    Top = 200
    Width = 1220
    Height = 676
    ActivePage = tabSede
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 3552822
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OwnerDraw = True
    OnDrawTab = pgcUnidadesDrawTab
    object tabSede: TTabSheet
      Caption = '  SEDE  '
      object pgcTipoEnvio: TPageControl
        Left = 0
        Top = 0
        Width = 1212
        Height = 644
        ActivePage = tabLoteSede
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OwnerDraw = True
        OnDrawTab = pgcTipoEnvioDrawTab
        object tabLoteSede: TTabSheet
          Caption = '  Lotes  '
          object pgcSituacao: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvLoteSede
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvLoteSede: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteSede: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
                Width = 1196
                Height = 580
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
          Caption = '  Individual  '
          object pgcSitIndivSede: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvIndivSede
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvIndivSede: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivSede: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
        Width = 1212
        Height = 644
        ActivePage = tabLoteUEQ
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OwnerDraw = True
        OnDrawTab = pgcTipoEnvioDrawTab
        object tabLoteUEQ: TTabSheet
          Caption = '  Lotes  '
          object pgcSitLoteUEQ: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvLoteUEQ
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvLoteUEQ: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteUEQ: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
                Width = 1196
                Height = 580
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
          Caption = '  Individual  '
          object pgcSitIndivUEQ: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvIndivUEQ
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvIndivUEQ: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivUEQ: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
        Width = 1212
        Height = 644
        ActivePage = tabLoteVarjota
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OwnerDraw = True
        OnDrawTab = pgcTipoEnvioDrawTab
        object tabLoteVarjota: TTabSheet
          Caption = '  Lotes  '
          object pgcSitLoteVarjota: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvLoteVarjota
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvLoteVarjota: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteVarjota: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
                Width = 1196
                Height = 580
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
          Caption = '  Individual  '
          object pgcSitIndivVarjota: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvIndivVarjota
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvIndivVarjota: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivVarjota: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
        Width = 1212
        Height = 644
        ActivePage = tabLoteSeisBocas
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5987163
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OwnerDraw = True
        OnDrawTab = pgcTipoEnvioDrawTab
        object tabLoteSeisBocas: TTabSheet
          Caption = '  Lotes  '
          object pgcSitLoteSeisBocas: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvLoteSeisBocas
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvLoteSeisBocas: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvLoteSeisBocas: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
                Width = 1196
                Height = 580
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
          Caption = '  Individual  '
          object pgcSitIndivSeisBocas: TPageControl
            Left = 0
            Top = 0
            Width = 1204
            Height = 612
            ActivePage = tabEnvIndivSeisBocas
            Align = alClient
            TabOrder = 0
            OwnerDraw = True
            OnDrawTab = pgcSituacaoDrawTab
            object tabEnvIndivSeisBocas: TTabSheet
              Caption = '  Enviadas  '
              object grdEnvIndivSeisBocas: TDBGridEh
                Left = 0
                Top = 0
                Width = 1196
                Height = 580
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
  object imgl_BotoesGrid: TImageList
    Left = 8
    Top = 8
    Bitmap = {
      494C010102000800040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000FF000000FF000000FFC7B1
      8E00E2D7C500E2D7C500E2D7C500E2D7C500E2D7C500E2D7C500E2D7C500E2D7
      C500C7B18E00000000FF000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000A2A0F6002E26EC00D0CDF90000000000000000FF000000FFEEE8DE00ECE5
      D900F6F2ED00EDE6DB00EDE6DB00EDE6DB00EDE6DB00EDE6DB00EDE6DB00F3F0
      EA00ECE5D900EEE8DE00000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D3D1FA009693F5000000000000000000000000000000000000000000ABA7
      F600241CED00231BEB00D9D8FA0000000000BD9F7000C3975900BB905300ECE5
      D900E4DAC900CCB89700CCB89700CCB89700CCB89700CCB89700CCB89700DED1
      BC00ECE5D900BB905300C3975900BD9F71000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000BAB7F700241CED007773F200000000000000000000000000C4C0F800271F
      EB00241CED00706BF1000000000000000000BF986000FFB46000EEAD6300ECE5
      D900DDD0BA00BBA17500BBA17500BBA17500BBA17500BBA17500BBA17500D4C4
      A900ECE5D900EEAD6300FFB46000BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000004C45EE00241CED009390F40000000000D8D6FA002F28EC00241C
      ED002A22EB00000000000000000000000000BF986000FFB46000EEAD6300ECE5
      D900FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00ECE5D900EEAD6300FFB46000BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C8C7F900241CEB00231BEB009C98F5003B34ED00241CED00241C
      ED009C98F500000000000000000000000000BF986000F5B06100BF935600C2A5
      7600D3BA9500D3BA9500D3BA9500D3BA9500D3BA9500D3BA9500D3BA9500D3BA
      9500C2A57600BF935600F5B06100BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008782F300241CED00241CED00241CED00241CED005852
      EF0000000000000000000000000000000000BF986000FFB46000FFB46000FFB4
      6000FFB46000FFB46000FFB46000FFB46000FFB46000FFB46000FFB46000FFB4
      6000D1A16200C1985D00FCB25E00BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000002E27EC00241CED00241CED00322AEC000000
      000000000000000000000000000000000000BF986000F5B06100C4965900C598
      5900FBB15F00FFB46000FFB46000FFB46000FFB46000FFB46000FFB46000FFB4
      60009A916E008AA8A100E5AB6500BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007974F200241CED00241CED00241CED003C35ED000000
      000000000000000000000000000000000000BF986000FFB46000FFB46000FFB4
      6000FFB46000FFB46000FFB46000FFB46000FFB46000FFB46000FFB46000FFB4
      6000D2A26400C2985E00FCB25E00BF9860000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009794F500241CED00241CED00241CED00241CED00241CED004E48
      EF0000000000000000000000000000000000CDB89700C3A16E00BF9C6800B793
      5A00C4A17000C4A17000C4A17000C4A17000C4A17000C4A17000C4A17000C4A1
      7000B7935A00BF9C6800C3A16E00CDB897000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000B4B1F700241CEB00241CED00241CED005A54F0008683F300241CED00241C
      ED006963F100000000000000000000000000000000FF000000FFEEE8DE00CFBC
      9D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00CFBC9D00EEE8DE00000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000CDCB
      F9002922EB00241CED00241CED004039ED0000000000000000006963F100241C
      ED00241CED00847FF3000000000000000000000000FF000000FFEEE8DE00CFBC
      9D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00CFBC9D00EEE8DE00000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000DFDEFB00342D
      EB00241CED00241CED002E26EC00D9D8FA00000000000000000000000000514A
      EF00241CED00241CED00D3D1FA0000000000000000FF000000FFEEE8DE00CFBC
      9D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D8C9B000C3A87A00C4A9
      7C00A07A3D00000000FF000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000463EEE00241C
      ED00241CED00241CEB00BBB8F800000000000000000000000000000000000000
      0000E1DFFB00E1DFFB000000000000000000000000FF000000FFEEE8DE00CFBC
      9D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BFA47900FFE8BB00C9AD
      7C00DDD0BB00000000FF000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D1D0F900342DEB00241C
      ED00342CEC00A8A4F60000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000FF000000FFEEE8DE00CFBC
      9D00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BFA47900C9AD7C00DDD0
      BB00000000FF000000FF000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000FF000000FF000000FFAE8E
      5A00BBA17500BBA17500BBA17500BBA17500BBA175009D783600DDD0BB000000
      00FF000000FF000000FF000000FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFE00700000000FFF1C00300000000
      F3E1000000000000F1C3000000000000F887000000000000F807000000000000
      FC0F000000000000FE1F000000000000FC1F000000000000F80F000000000000
      F007C00300000000E0C3C00300000000C0E1C00700000000C1F3C00700000000
      83FFC00F00000000FFFFE01F00000000}
  end
end
