unit swe1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls, Registry, ActiveX;

type
  TsSWE1 = class(TService)
    // Timer utilizado para controlar a execução do processo periodicamente...
    tmrSWE: TTimer;
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure tmrSWETimer(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

  procedure LogAnalitico(AMsg: String; APath: String = 'C:\SWE'; AAddDtHr: Boolean = True);

var
  sSWE1: TsSWE1;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  sSWE1.Controller(CtrlCode);
end;

function TsSWE1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsSWE1.ServiceAfterInstall(Sender: TService);
var Reg: TRegistry;
begin
	// registramos no registro do windows a descrição para nosso serviço...
	Reg	:= TRegistry.Create(KEY_READ or KEY_WRITE);
  try
  	Reg.RootKey	:= HKEY_LOCAL_MACHINE;
		if Reg.OpenKey( '\SYSTEM\CurrentControlSet\Services\' + Name, false ) then
     begin
			Reg.WriteString( 'Description', 'SWE - Serviço do Windows - Exemplo didático' );
			Reg.CloseKey;
		end;
	finally
		Reg.Free;
	end;
end;

procedure TsSWE1.ServiceExecute(Sender: TService);
begin
	// habilitamos nossos processos...
	tmrSWE.Enabled	:= True;
  while not Terminated do begin
  	// aguarada nosso processos ser encerrados...
		ServiceThread.ProcessRequests(True);
     // caso seja encerrado vamos parar o timer...
     tmrSWE.Enabled	:= False;
  end;
end;

procedure TsSWE1.ServiceCreate(Sender: TObject);
begin
  // inicializar alguns recursos necessários para este tipo de aplicação...
	CoInitialize(nil);
end;

procedure TsSWE1.ServiceDestroy(Sender: TObject);
begin
	CoUninitialize;
end;

procedure TsSWE1.tmrSWETimer(Sender: TObject);
begin
	// rotina de tranmissão dos dados...
  LogAnalitico( 'Inicio da transmissão' );
  try
  	// desabilitamos o timer para evitar a chamada de outra transmissão, sem ter acabado a atual...
  	LogAnalitico( 'Desabilita temporizador' );
  	tmrSWE.Enabled	:= False;
     try
     	// chamamos a rotina de transmissão dos dados...
  		LogAnalitico( 'Chama a rotina' );

        // aqui vc chama sua rotina
			Sleep(5000);

  		LogAnalitico( 'Chama a rotina OK' );
     except
        on e: exception do begin
        	try
              LogAnalitico( 'Log de erro de exceção' );
              // geramos o erro no gerenciador de eventos do windows...
              LogMessage( e.Message, EVENTLOG_ERROR_TYPE, 0, 4 );
              LogAnalitico( 'Log de erro de exceção OK' );
           except
              tmrSWE.Enabled	:= True;
              LogAnalitico( 'Erro no tratamento de erros - except.' );
				end;
        end;
     end;
  finally
     // habilitamos o timer para que possa ser iniciado novamente o processo...
     tmrSWE.Enabled	:= True;
  end;
end;



procedure LogAnalitico(AMsg: String; APath: String = 'C:\SWE'; AAddDtHr: Boolean = True);
var vF: TextFile;
	vPath, vFileName: String;
begin
	if APath = '' then
		vPath	:= 'C:\SWE\'
  else
		vPath	:= APath + '\';

	if not DirectoryExists(vPath) then
     ForceDirectories(vPath);

	vFileName := vPath + FormatDateTime( 'YYYYMM', Date ) + 'LMA' + '.TXT';

	AssignFile(vF, vFileName);
	if FileExists(vFileName) then
		Append(vF)
  else
		Rewrite(vF);

	if AAddDtHr then
		writeln(vF, FormatDateTime( 'dd/mm/yyyy hh:MM:ss', now ) + ' - ' + AMsg)
	else
		writeln(vF, AMsg);

	CloseFile(vF);
end;

end.
