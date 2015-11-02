unit TheMyPopup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LclIntf, Forms, LMessages, Controls, Graphics,
  Dialogs, CheckLst, LclType, LclProc, InterfaceBase, ExtCtrls, StdCtrls;

const
   WM_MOUSEACTIVATE = $0021; //https://code.google.com/p/thtmlviewer/source/browse/trunk/source/htmlmisc.pas?r=219
   MA_NOACTIVATE = 3;
type

  { TMyPopup }

  TMyPopup = class(TForm)
    CheckListBox1: TCheckListBox;
    Edit1: TEdit;
    Shape1: TShape;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { private declarations }
    procedure CMShowingChanged(var Message: TLMessage); message CM_SHOWINGCHANGED;

    procedure WMMouseActivate(var Msg: TLMessage); message WM_MOUSEACTIVATE;
  public
    { public declarations }
  end;

  { TMyHintWindowRendered }

  TMyHintWindowRendered = class(THintWindowRendered)
  protected
    procedure DoShowWindow;override;
    procedure WMNCHitTest(var Message: TLMessage); message LM_NCHITTEST;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
        function IsHintMsg(Msg: TMsg): Boolean; override;

  end;

procedure ShowMyPopup(const Position: TPoint;
     const OnShowHide: TNotifyEvent = nil);
var
  MyPopup: TMyPopup;

implementation

{$R *.lfm}


procedure ShowMyPopup(const Position: TPoint;
   const OnShowHide: TNotifyEvent = nil);
var
  PopupForm:TMyHintWindowRendered;// THintWindowRendered;//TMyPopup;
begin
  PopupForm := TMyHintWindowRendered{TMyPopup}.Create(nil);
  PopupForm.OnMOuseDown := @PopupForm.FormMouseDown;
  with TShape.create(PopupFOrm) do
  begin
    parent := PopupForm;
    Align := alLeft;
    Pen.Color := clFuchsia;
    //visible := false;
    OnMOuseDown := @PopupForm.FormMouseDown
  end;
  with TEdit.Create(PopupFOrm) do
  begin
    //parent := popupform;
  end;
  PopupFOrm.ActiveControl := nil;
  //PopupForm.Initialize(Position, ADate, CalendarDisplaySettings);
  //PopupForm.FOnReturnDate := OnReturnDate;
  //PopupForm.OnShow := OnShowHide;
  //PopupForm.OnHide := OnShowHide;
  //PopupForm.Show;
  PopupFOrm.HintRectAdjust := Rect(0, 0, 500, 50);
  PopupForm.OffsetHintRect(Position);
  PopupForm.ActivateRendered;
end;

procedure TMyHintWindowRendered.DoShowWindow;
begin
  //inherited DoShowWindow;
end;

procedure TMyHintWindowRendered.WMNCHitTest(var Message: TLMessage);
begin
  Message.Result := HTNOWHERE;//HTTRANSPARENT;   //WOY!! INI BISA DIMAINKAN (PLAY WITH THIS)
end;

procedure TMyHintWindowRendered.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if BUtton <> mbLeft then close;
  //ShowMessage(Sender.ClassName + ' woles! =' +inttostr(X));
end;

function TMyHintWindowRendered.IsHintMsg(Msg: TMsg): Boolean;
begin
  case Msg.message of
    LM_KEYFIRST..LM_KEYLAST,
    //CM_ACTIVATE, CM_DEACTIVATE,
    CM_APPSYSCOMMAND,
    LM_COMMAND,
    LM_LBUTTONDOWN..LM_MOUSELAST,
    LM_NCMOUSEMOVE :
      Result := True;
    else
      Result := False;
  end;
end;

{ TMyPopup }

procedure TMyPopup.FormDeactivate(Sender: TObject);
begin
  Hide;
  Close;
end;

procedure TMyPopup.CMShowingChanged(var Message: TLMessage);
const
  ShowFlags: array[Boolean] of UINT = (
    SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_HIDEWINDOW,
    SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_SHOWWINDOW);
begin
  SetWindowPos(WindowHandle, 0, 0, 0, 0, 0, ShowFlags[Showing]);
end;

procedure TMyPopup.WMMouseActivate(var Msg: TLMessage);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TMyPopup.FormCreate(Sender: TObject);
begin
    Application.AddOnDeactivateHandler(@FormDeactivate);
end;

procedure TMyPopup.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Application.RemoveOnDeactivateHandler(@FormDeactivate);
  CloseAction := caFree;
end;

end.

