program Chuvak;

uses
  Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain},
  UChuvak in 'UChuvak.pas';

{$R *.res}

begin
  {$IF COMPILERVERSION >= 17}
  ReportMemoryLeaksOnShutdown := True;
  {$IFEND}
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
