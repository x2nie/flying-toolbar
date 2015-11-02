unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ComboEx, EditBtn, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CalcEdit1: TCalcEdit;
    CheckComboBox1: TCheckComboBox;
    DateEdit1: TDateEdit;
    DateTimePicker1: TDateTimePicker;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
    procedure MyPopupShowHide(Sender: TObject);
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  TheMyPopup;
{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  PopupOrigin: TPoint;
  ADate: TDateTime;
begin
  //inherited ButtonClick;

  PopupOrigin := Button1.ControlToScreen(Point(0, Button1.Height));
  ShowMyPopup(PopupOrigin, //ADate, CalendarDisplaySettings, @CalendarPopupReturnDate,
  @MyPopupShowHide);
  //Do this after the dialog, otherwise it just looks silly
  //if FocusOnButtonClick then FocusAndMaybeSelectAll;

end;

procedure TForm1.MyPopupShowHide(Sender: TObject);
begin

end;

end.

