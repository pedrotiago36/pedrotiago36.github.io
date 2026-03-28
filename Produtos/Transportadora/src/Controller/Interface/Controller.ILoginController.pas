unit Controller.ILoginController;

interface

uses
  View.ILoginView;

type
  ILoginController = interface
    ['{8D4F2A1C-6E9B-4F3A-7C1E-5B8D3F2A9E6C}']
    procedure BindView(const AView: ILoginView);
    procedure ExecuteLogin;
  end;

implementation

end.
