unit Controller.IConfiguracaoView;

interface

uses
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics;

type
  IControllerConfiguracaoView = interface
    ['{C9D1E2F3-A4B5-6789-CDEF-012345678901}']
    procedure Inicializar;
    procedure Salvar;
    procedure SelecionarDiretorio(const AEdit: TEdit);
    procedure AtualizarCaptionThread(const ACheck: TCheckBox);
    procedure PreencherTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox);
    procedure ColetarTela(const AEdtUrlHomologacao, AEdtUrlProducao,
      AEdtDirEnviados, AEdtDirErro, AEdtDirIni, AEdtDataEnvio: TEdit;
      const AChbThread: TCheckBox);
    procedure ExibirMensagemStatus(const ALbl: TLabel;
      const AMensagem: string; const ACor: TColor);
  end;

implementation

end.
