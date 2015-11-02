program Demo1;

uses
  Forms, Unit1, Lizard,
  Lizard_Toolbar
  { you can add units after this };

{$R *.res}

begin

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

