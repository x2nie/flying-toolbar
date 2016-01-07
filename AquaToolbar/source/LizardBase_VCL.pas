unit LizardBase_VCL;

{$I Lizard_Ver.inc}

interface

uses Windows,Classes, Controls,ExtCtrls;

type

  { TLzbPanel }

  TLzbPanel = class(TCustomControl)
  protected
    procedure Paint; override;
    procedure PaintSurface(); virtual; //unity, because another backend may have override paint
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

{ TLzbPanel }

procedure TLzbPanel.Paint;
begin
  PaintSurface();
end;

procedure TLzbPanel.PaintSurface;
begin
  inherited paint;
end;

{ TDockManager }

function TDockManager.AutoFreeByControl: Boolean;
begin
  Result := True;
end;

procedure TDockManager.BeginUpdate;
begin

end;

constructor TDockManager.Create(ADockSite: TWinControl);
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

procedure TDockManager.SetReplacingControl(Control: TControl);
begin

end;

end.

