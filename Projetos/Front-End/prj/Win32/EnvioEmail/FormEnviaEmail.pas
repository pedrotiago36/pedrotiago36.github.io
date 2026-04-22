unit FormEnviaEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, UnitEnviaEmail;

type
  TFormEnvia = class(TForm)
    edtPara: TEdit;
    mmMensagem: TMemo;
    btnEnviar: TButton;
    procedure btnEnviarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormEnvia: TFormEnvia;

implementation

uses
  IdSSLOpenSSLHeaders;

{$R *.dfm}

procedure TFormEnvia.btnEnviarClick(Sender: TObject);
var
  Config: TConfigEmail;
  Resultado: string;
begin
  if Trim(edtPara.Text) = '' then
  begin
    ShowMessage('Digite um e-mail destinatário!');
    Exit;
  end;

  try
    Config := CarregarConfig('Config.ini');
//    ShowMessage(WhichFailedToLoad);
    Resultado := EnviarEmail(Config, edtPara.Text, mmMensagem.Text);
    ShowMessage(Resultado);
  except
    on E: Exception do
      ShowMessage('Erro ao carregar configuração: ' + E.Message);
  end;
end;

end.
