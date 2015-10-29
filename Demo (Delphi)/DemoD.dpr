program DemoD;

uses
  Controls,
  Forms,
  Demo1 in 'Demo1.pas' {DemoForm},
  TBx2_LCL in '..\source\TBx2_LCL.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Toolbar97 Demo';
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;
end.
