unit Model.ILeituraArquivos;

interface

uses
  System.Generics.Collections;

type
  TRegistroRps = record
    NumeroRps        : string;
    SerieRps         : string;
    DataEmissao      : string;
    Tomador          : string;
    ValorServico     : string;
    NumeroNFSe       : string;
    CodigoVerificacao: string;
    Situacao         : string;
    MotivoCancel     : string;
    LinhaOriginal    : string;
  end;

  TListaRps = TList<TRegistroRps>;

  ILeituraArquivos = interface
    ['{D4E5F6A7-B8C9-0123-DEF0-123456789012}']
    procedure CarregarRpsEnviadas(const ACaminhoBase: string;
      const AAno, AMes: Word; const ALista: TListaRps);
    procedure CarregarRpsCanceladas(const ACaminhoBase: string;
      const AAno, AMes: Word; const ALista: TListaRps);
    function ContarRegistros(const ACaminhoBase: string;
      const AAno, AMes: Word; const ASituacao: string): Integer;
  end;

implementation

end.
