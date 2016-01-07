unit Unit1;

interface

uses
  Classes, SysUtils, {FileUtil,} Forms, Controls, Graphics, Dialogs, Lizard,
  Lizard_Toolbar, ExtCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    LzDock1: TLzDock;
    LzToolbar1: TLzToolbar;
    LzToolbar2: TLzToolbar;
    LzToolbar3: TLzToolbar;
  
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



end.

