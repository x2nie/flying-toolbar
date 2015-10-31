unit TBx2_VCL7;

interface
uses Windows, Classes, Controls,ExtCtrls;

type
  TDockX2Ctrl = class(TCustomPanel)
  private
  
    //FAutoSizingLockCount
    FUpdatingBounds:Integer;    { Incremented while internally changing the bounds. This allows
                                 it to move the toolbar freely in design mode and prevents the
                                 SizeChanging protected method from begin called }

  public
    //integrate Lazarus
    procedure DisableAutoSizing;
    procedure EnableAutoSizing;
    function AutoSizeDelayed: boolean;
  end;

  { imitate the lazarus class name used, but mimimum class implementation.
    so it doesn't inherit TDockTree for simplicity }
  TDockManager = class(TInterfacedObject, IDockManager)
  public
    constructor Create(ADockSite: TWinControl); virtual;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    procedure GetControlBounds(Control: TControl;
                               out AControlBounds: TRect); virtual; abstract;
    procedure InsertControl(Control: TControl; InsertAt: TAlign;
                            DropCtl: TControl); overload;virtual;  abstract; 
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure PaintSite(DC: HDC); virtual;
    procedure PositionDockRect(Client, DropCtl: TControl; DropAlign: TAlign;
                               var DockRect: TRect); {overload;}virtual; abstract;
    procedure RemoveControl(Control: TControl); virtual; abstract;
    procedure ResetBounds(Force: Boolean); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure SetReplacingControl(Control: TControl); virtual;
    //Lazarus things:
    procedure InsertControl(ADockObject: TDragDockObject); overload; virtual;
    //procedure PositionDockRect(ADockObject: TDragDockObject); overload; virtual;
    //procedure MessageHandler(Sender: TControl; var Message: TLMessage); virtual;
    function GetDockEdge(ADockObject: TDragDockObject): boolean; virtual;
    function AutoFreeByControl: Boolean; virtual;
  end;

implementation

{ TDockX2Ctrl }

function TDockX2Ctrl.AutoSizeDelayed: boolean;
begin
  Result:=(FUpdatingBounds>0);
end;

procedure TDockX2Ctrl.DisableAutoSizing;
begin
  Inc(FUpdatingBounds);
end;

procedure TDockX2Ctrl.EnableAutoSizing;
begin
  Dec(FUpdatingBounds);
end;

{ TDockManager }

(*procedure TDockManager.PositionDockRect(ADockObject: TDragDockObject);
begin
{ for now: defer to old PositionDockRect.
  Overridden methods should determine DropOnControl and DropAlign, before
    calling inherited method.

  {with ADockObject do
  begin
    if DropAlign = alNone then
    begin
      if DropOnControl <> nil then
        DropAlign := DropOnControl.GetDockEdge(DropOnControl.ScreenToClient(DragPos))
      else
        DropAlign := Control.GetDockEdge(DragTargetPos);
    end;
    PositionDockRect(Control, DropOnControl, DropAlign, FDockRect);
  end;}
end;*)

procedure TDockManager.SetReplacingControl(Control: TControl);
begin

end;

function TDockManager.AutoFreeByControl: Boolean;
begin
  Result := True;
end;

constructor TDockManager.Create(ADockSite: TWinControl);
begin
  inherited Create;
end;

procedure TDockManager.BeginUpdate;
begin

end;

procedure TDockManager.EndUpdate;
begin

end;

function TDockManager.GetDockEdge(ADockObject: TDragDockObject): boolean;
begin
  { Determine the DropAlign.
    ADockObject contains valid DragTarget, DragPos, DragTargetPos relative
    dock site, and DropOnControl.
    Return True if ADockObject.DropAlign has been determined.
  }
  Result := False; // use the DockSite.GetDockEdge
end;

procedure TDockManager.InsertControl(ADockObject: TDragDockObject);
begin
  InsertControl(ADockObject.Control,ADockObject.DropAlign,
                ADockObject.DropOnControl);
end;

procedure TDockManager.PaintSite(DC: HDC);
begin

end;

  

end.
