program chuvak;

uses
  Forms,
  UfrmMain in 'UfrmMain.pas' {FrmMain},
  Uchuvak in 'Uchuvak.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
