program DemoD;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{$IFNDEF FPC}
{$ELSE}
  Interfaces,
{$ENDIF}
  Controls,
  Forms,
  Demo1 in 'Demo1.pas' {DemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Toolbar97 Demo';
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.
