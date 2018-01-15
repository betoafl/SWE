program swe;

uses
  SvcMgr,
  swe1 in 'swe1.pas' {sSWE1: TService};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TsSWE1, sSWE1);
  Application.Run;
end.
