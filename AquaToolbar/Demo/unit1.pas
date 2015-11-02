unit Unit1;

interface

uses
  Classes, SysUtils, {FileUtil,} Forms, Controls, Graphics, Dialogs, Lizard,
  Lizard_Toolbar, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    DockX2_1: TLzDock;
    ToolbarX2_1: TLzToolbar;
    ToolbarX2_2: TLzToolbar;
    ToolbarX2_3: TLzToolbar;
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

