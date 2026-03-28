unit Controller.TLoginController;

interface

uses
  Controller.ILoginController,
  View.ILoginView,
  Model.ILogin;

type
  TLoginController = class(TInterfacedObject, ILoginController)
  strict private
    FView  : ILoginView;
    FModel : ILogin;
  public
    constructor Create(const AModel: ILogin);
    procedure BindView(const AView: ILoginView);
    procedure ExecuteLogin;
  end;

function NewLoginController(const AModel: ILogin): ILoginController;

implementation

function NewLoginController(const AModel: ILogin): ILoginController;
begin
  Result := TLoginController.Create(AModel);
end;

{ TLoginController }

constructor TLoginController.Create(const AModel: ILogin);
begin
  inherited Create;
  FModel := AModel;
end;

procedure TLoginController.BindView(const AView: ILoginView);
begin
  FView := AView;
end;

procedure TLoginController.ExecuteLogin;
begin
  FModel.Authenticate(
    FView.CollectCredentials,
    procedure(AMessage: string) begin FView.NotifySuccess(AMessage); end,
    procedure(AMessage: string) begin FView.NotifyFailure(AMessage); end
  );
end;

end.
