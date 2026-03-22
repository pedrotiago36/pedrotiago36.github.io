unit Model.ILeituraIni;

{
  ============================================================
  Model.ILeituraIni — Interface do leitor do NFSe_Servico.ini
  ============================================================
  Define o contrato para leitura das configuracoes do servico.

  Metodos:
    ResolverCaminhoIni : localiza o arquivo .ini subindo a arvore
    Carregar           : le o .ini e retorna TDadosConfiguracaoEnvio
  ============================================================
}

interface

uses
  Shared.Tipos; { TDadosConfiguracaoEnvio }

type
  ILeituraIni = interface
    ['{E5F6A7B8-C9D0-0005-EFA1-567890123456}']
    { Sobe ate 5 niveis a partir de AExePath procurando Config\NFSe_Servico.ini }
    function ResolverCaminhoIni(const AExePath: string): string;
    { Le o .ini e preenche TDadosConfiguracaoEnvio com Mes/Ano informados }
    function Carregar(
      const AExePath: string;
      const AMes    : Integer;
      const AAno    : Integer): TDadosConfiguracaoEnvio;
  end;

implementation

end.
