unit View.ILoginView;

interface

uses
  Model.ILogin;

type
  ILoginView = interface
    ['{5E2A8F1D-3C9B-4E7A-8D2F-6B1E9C4A7F3D}']
    function  CollectCredentials: TLoginCredentials;
    procedure NotifySuccess(const AMessage: string);
    procedure NotifyFailure(const AMessage: string);
  end;

implementation

end.
