unit TBx2;

{
  ToolBench X2
  Copyright (c) 2013 by x2nie 
  a custom UI based on Toolbar97

  -------------------------------------------
  Toolbar97
  Copyright (C) 1998-2004 by Jordan Russell
  http://www.jrsoftware.org/

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
}


interface

{$DEFINE TB97DisableLock}
{.$DEFINE TBX2_DRAGDROP}
{$I TBx2_Ver.inc}

uses
{$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Types, //messages,
  LazMessages,
{$ELSE}
  Windows, Messages,
{$ENDIF}
  Classes, Controls, Forms, Graphics, ExtCtrls {shape of floating offscreen},
  ImgList,
{$IFDEF TBX2_GR32}
  GR32, GR32_Image,
{$ENDIF}

//SURFACE BACKEND
{$IFDEF FPC}
  TBx2_LCL,
{$ELSE}
  TBx2_VCL7,
{$ENDIF}

  TBx2_Const;


type
  { TDockX2 }

  TDockBoundLinesValues = (blTop, blBottom, blLeft, blRight);
  TDockBoundLines = set of TDockBoundLinesValues;
  TDockPosition = (dpTop, dpBottom, dpLeft, dpRight);
  TDockType = (dtNotDocked, dtTopBottom, dtLeftRight);
  TDockableTo = set of TDockPosition;

  TCustomToolWindowX2 = class;

  TInsertRemoveEvent = procedure(Sender: TObject; Inserting: Boolean;
    Bar: TCustomToolWindowX2) of object;
  TRequestDockEvent = procedure(Sender: TObject; Bar: TCustomToolWindowX2;
    var Accept: Boolean) of object;


  //TDockX2 = class({$IFDEF TBX2_GR32}TCustomPaintBox32{$ELSE}TCustomPanel{$ENDIF})
  TDockX2 = class(TDockX2Ctrl)
  private
    FPosition: TDockPosition;
    FAllowDrag: Boolean;
    
    FFixAlign: Boolean;
    FLimitToOneRow: Boolean;
    FOnInsertRemoveBar: TInsertRemoveEvent;
    FOnRequestDock: TRequestDockEvent;

    procedure SetPosition(const Value: TDockPosition);
    procedure SetFixAlign(const Value: Boolean);

  private
    { Internal }
    FDisableArrangeToolbars: Integer;  { Increment to disable ArrangeToolbars }
    FArrangeToolbarsNeeded, FArrangeToolbarsClipPoses: Boolean;
    DockList: TList;  { List of the toolbars docked, and those floating and have LastDock
                        pointing to the dock. Items are casted in TCustomToolWindow97's. }
    DockVisibleList: TList;  { Similar to DockList, but lists only docked and visible toolbars }
    RowSizes: TList;  { List of the width or height of each row, depending on what Position
                        is set to. Items are casted info Longint's }

    { Internal }
    procedure ArrangeToolbars (const ClipPoses: Boolean);
    procedure BuildRowInfo;
    procedure ChangeDockList (const Insert: Boolean; const Bar: TCustomToolWindowX2);
    procedure ChangeWidthHeight (const NewWidth, NewHeight: Integer);
    function GetDesignModeRowOf (const XY: Integer): Integer;
    function GetRowOf (const XY: Integer; var Before: Boolean): Integer;
    function GetNumberOfToolbarsOnRow (const Row: Integer;
      const NotIncluding: TCustomToolWindowX2): Integer;
    
    function HasVisibleToolbars: Boolean;
    procedure InsertRowBefore (const BeforeRow: Integer);
    procedure RemoveBlankRows;
    function ToolbarVisibleOnDock (const AToolbar: TCustomToolWindowX2): Boolean;
    procedure ToolbarVisibilityChanged (const Bar: TCustomToolWindowX2;
      const ForceRemove: Boolean);

  protected
    procedure AlignControls (AControl: TControl; var Rect: TRect); override;  
    //procedure Loaded; override; tcustompaintbox = public
    {$IFDEF TBX2_GR32}
    procedure DoPaintBuffer; override;
    {$ELSE}
    procedure Paint;override;
    {$ENDIF}

    {$IFNDEF TBX2_DRAGDROP}
    procedure DoDockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override; //tcustompaintbox = public

    procedure BeginUpdate;
    procedure EndUpdate;

    function GetHighestRow: Integer;
    function GetRowSize (const Row: Integer;
      const DefaultToolbar: TCustomToolWindowX2): Integer;
  published
    property Color default clBtnFace;
    property FixAlign: Boolean read FFixAlign write SetFixAlign default False;
    property LimitToOneRow: Boolean read FLimitToOneRow write FLimitToOneRow default False;
    property Position: TDockPosition read FPosition write SetPosition default dpTop;

    property OnRequestDock: TRequestDockEvent read FOnRequestDock write FOnRequestDock;
  end;

  TFloatingWindowParent = class(TForm)
  private
    FParentForm: TCustomForm ;
    FShouldShow: Boolean;
    procedure CMShowingChanged (var Message: TMessage); message CM_SHOWINGCHANGED;

  protected
    procedure CreateParams (var Params: TCreateParams); override;
  public
    constructor Create (AOwner: TComponent); override;

    property ParentForm: TCustomForm read FParentForm;

  published
  end;

  TFloatingDragWindow = class(TForm)
  private
    FShape : TShape;
    function GetBorderLen: Integer;
    procedure SetBorderLen(const Value: Integer);
  protected
  public
    constructor Create (AOwner: TComponent); override;
    property BorderLen : Integer read GetBorderLen write SetBorderLen;
  published
  end;

  { TCustomToolWindow97 }

  TDockChangingExEvent = procedure(Sender: TObject; DockingTo: TDockX2) of object;
  TDragHandleStyle = (dhDouble, dhNone, dhSingle);
  TToolWindowDockMode = (dmCanFloat, dmCannotFloat, dmCannotFloatOrChangeDocks);
  TToolWindowFloatingMode = (fmOnTopOfParentForm, fmOnTopOfAllForms);
  TToolWindowParams = record
    CallAlignControls, ResizeEightCorner, ResizeClipCursor: Boolean;
  end;
  TToolWindowSizeHandle = (twshLeft, twshRight, twshTop, twshTopLeft,
    twshTopRight, twshBottom, twshBottomLeft, twshBottomRight);
    { ^ must be in same order as HTLEFT..HTBOTTOMRIGHT }
  TToolWindowNCRedrawWhatElement = (twrdBorder, twrdCaption, twrdCloseButton);
  TToolWindowNCRedrawWhat = set of TToolWindowNCRedrawWhatElement;
  TPositionReadIntProc = function(const ToolbarName, Value: String; const Default: Longint;
    const ExtraData: Pointer): Longint;
  TPositionReadStringProc = function(const ToolbarName, Value, Default: String;
    const ExtraData: Pointer): String;
  TPositionWriteIntProc = procedure(const ToolbarName, Value: String; const Data: Longint;
    const ExtraData: Pointer);
  TPositionWriteStringProc = procedure(const ToolbarName, Value, Data: String;
    const ExtraData: Pointer);

  //TCustomToolWindowX2 = class({$IFDEF TBX2_GR32}TCustomPaintBox32{$ELSE}TCustomPanel{$ENDIF})
  TCustomToolWindowX2 = class(TDockX2Ctrl)
  private
    FActivateParent, FHideWhenInactive, FCloseButton, FCloseButtonWhenDocked,
      FFullSize, FResizable, FShowCaption, FUseLastDock: Boolean;

    FDockRow: Integer;
    FDockPos: Integer;
    FDockedTo: TDockX2;
    FOnClose, FOnDockChanged, FOnDockChanging, FOnMove, FOnRecreated,
      FOnRecreating, FOnResize, FOnVisibleChanged: TNotifyEvent;
    FOnDockChangingEx, FOnDockChangingHidden: TDockChangingExEvent;
    FLastDockType: TDockType;
    FLastDockTypeSet: Boolean;
    FFloatingMode: TToolWindowFloatingMode;
    FDockForms: TList;
    FParams: TToolWindowParams;
    FNonClientWidth, FNonClientHeight: Integer;
    { Misc. }
    {FUpdatingBounds,}           { Incremented while internally changing the bounds. This allows
                                 it to move the toolbar freely in design mode and prevents the
                                 SizeChanging protected method from begin called }
    FDisableArrangeControls,   { Incremented to disable ArrangeControls }
    FDisableOnMove,            { Incremented to prevent WM_MOVE handler from calling the OnMoved handler }
    FHidden: Integer;          { Incremented while the toolbar is temporarily hidden }
    FArrangeNeeded, FMoved: Boolean;
    FInactiveCaption: Boolean; { True when the caption of the toolbar is currently the inactive color }
    FFloatingTopLeft: TPoint;
    FFloatingRect: TRect;
    FDocked: Boolean;
    FSavedAtRunTime: Boolean;

    { When floating. These are not used in design mode }
    FFloatParent: TFloatingWindowParent; { Run-time only: The actual Parent of the toolbar when it is floating }
    FCloseButtonDown: Boolean; { True if Close button is currently depressed }
    FLastDock: TDockX2;
    FBorderStyle: TBorderStyle;
    FDragHandleStyle: TDragHandleStyle;
    FDockableTo: TDockableTo;
    FDockMode: TToolWindowDockMode;
    FDefaultDock: TDockX2;
    FImageList: TCustomImageList;
    FImageChangeLink: TChangeLink;


    procedure CalculateNonClientSizes (R: PRect);
    procedure SetDockedTo(const Value: TDockX2);
    procedure SetDockPos(const Value: Integer);
    procedure SetDockRow(const Value: Integer);
    procedure SetFullSize(const Value: Boolean);
    procedure UpdateVisibility;
    function IsLastDockStored: Boolean;
    procedure SetLastDock(Value: TDockX2);
    procedure Moved;
    procedure MoveOnScreen (const OnlyIfFullyOffscreen: Boolean);
    function GetShowingState: Boolean;

    procedure DrawDockedNCArea {(const DrawToDC: Boolean; const ADC: HDC;const Clip: HRGN)};
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetDragHandleStyle(const Value: TDragHandleStyle);
    procedure SetCloseButtonWhenDocked(const Value: Boolean);
    procedure SetCloseButton(const Value: Boolean);
    procedure SetFloatingMode(const Value: TToolWindowFloatingMode);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetDefaultDock(const Value: TDockX2);
    procedure DrawDraggingOutline (const DC: HDC; const NewRect, OldRect: PRect;
      const NewDocking, OldDocking: Boolean);
    procedure SetResizable(const Value: Boolean);
    procedure SetRowsMin(const Value: Integer);
    procedure SetImagesList(const Value: TCustomImageList);
    function GetWeight: Integer;
    //procedure WMNCCalcSize (var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    //procedure WMNCPaint (var Message: TMessage); message WM_NCPAINT;
  protected
    FRowsMin: Integer;
    function GetClientRect: TRect; override;
    procedure CustomArrangeControls (const PreviousDockType: TDockType;
      const DockingTo: TDockX2; const Resize: Boolean);
    procedure DoMove; dynamic;
    {$IFDEF TBX2_GR32}
    procedure DoPaintBuffer; override;
    {$ELSE}
    procedure Paint;override;
    {$ENDIF}

    procedure GetParams (var Params: TToolWindowParams); dynamic;

    procedure DoDockChangingHidden (DockingTo: TDockX2); dynamic;
    procedure GetBarSize (var ASize: Integer; const DockType: TDockType); virtual; abstract;
    function OrderControls (CanMoveControls: Boolean; PreviousDockType: TDockType;
      DockingTo: TDockX2): TPoint; virtual; abstract;
    procedure SizeChanging (const AWidth, AHeight: Integer); virtual;
    procedure ArrangeControls;
    procedure InitializeOrdering; dynamic;
    procedure ImageListChanged(Sender: TObject); virtual;

    { Overridden methods }
    procedure AlignControls (AControl: TControl; var Rect: TRect); override;
    procedure SetParent (AParent: TWinControl); override;
    procedure GetDockRowSize (var AHeightOrWidth: Integer);
    procedure Loaded; override;


    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function ChildControlTransparent (Ctl: TControl): Boolean; dynamic;

    //property CloseButtonWhenDocked: Boolean read FCloseButtonWhenDocked write SetCloseButtonWhenDocked default False;
    property LastDock: TDockX2 read FLastDock write SetLastDock stored IsLastDockStored;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property CloseButton: Boolean read FCloseButton write SetCloseButton default True;
    property CloseButtonWhenDocked: Boolean read FCloseButtonWhenDocked write SetCloseButtonWhenDocked default False;
    property DefaultDock: TDockX2 read FDefaultDock write SetDefaultDock;
    property DockableTo: TDockableTo read FDockableTo write FDockableTo default [dpTop, dpBottom, dpLeft, dpRight];
    property DockMode: TToolWindowDockMode read FDockMode write FDockMode default dmCanFloat;
    property DragHandleStyle: TDragHandleStyle read FDragHandleStyle write SetDragHandleStyle default dhDouble;
    property FloatingMode: TToolWindowFloatingMode read FFloatingMode write SetFloatingMode default fmOnTopOfParentForm;
    property FullSize: Boolean read FFullSize write SetFullSize default False;
    property HideWhenInactive: Boolean read FHideWhenInactive write FHideWhenInactive default True;
    property Images: TCustomImageList read FImageList write SetImagesList;
    property Resizable: Boolean read FResizable write SetResizable default True;
    property Params: TToolWindowParams read FParams;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property RowsMin : Integer read FRowsMin write SetRowsMin default 1;
    property Weight : Integer read GetWeight; //width or height
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    {$IFDEF TBX2_DRAGDROP}
    procedure BeginMoving (const InitX, InitY: Integer);
    {$ENDIF}
    property Docked: Boolean read FDocked;
    procedure EndUpdate;
    procedure AddFloatingNCAreaToSize (var S: TPoint);
    procedure AddDockForm (const Form: {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm $ENDIF});
    procedure SetBounds (ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure GetDockedNCArea (var TopLeft, BottomRight: TPoint;
      const LeftRight: Boolean);
    
    function GetFloatingBorderSize: TPoint;
    procedure GetFloatingNCArea (var TopLeft, BottomRight: TPoint);
    procedure AddDockedNCAreaToSize (var S: TPoint; const LeftRight: Boolean);
    procedure RemoveDockForm (const Form: {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm $ENDIF});
        
    property DockedTo: TDockX2 read FDockedTo write SetDockedTo stored False;
    property DockPos: Integer read FDockPos write SetDockPos default -1;
    property DockRow: Integer read FDockRow write SetDockRow default 0;
  published
  end;

const
  //DragHandleSizes[CloseButtonWhenDocked, DragHandleStyle];
  DragHandleSizes: array[Boolean, TDragHandleStyle] of Integer =
    //((9, 0, 6), (14, 14, 14));
    ((11, 0, 8), (14, 14, 14));
  DragHandleOffsets: array[Boolean, TDragHandleStyle] of Integer =
    ((2, 0, 2), (3, 0, 5));
  DockedBorderSize = 2;
  DockedBorderSize2 = DockedBorderSize*2;
  PositionLeftOrRight = [dpLeft, dpRight];

function GetDockTypeOf (const Control: TDockX2): TDockType;
///function GetToolWindowParentForm (const ToolWindow: TCustomToolWindowX2):  {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF};

implementation
uses
  Registry, IniFiles, SysUtils,
  {$IFDEF FPC}LCLStrConsts, {$ELSE} Consts, {$ENDIF}
  TBx2_Common ;

const

  DefaultBarWidthHeight = 8;

  ForceDockAtTopRow = 0;
  ForceDockAtLeftPos = -8;


var
  FloatingToolWindows: TList = nil;
  UFloatingDragWindow :  TFloatingDragWindow = nil;


{$IFDEF FPC}
function MapWindowPoints(hWndFrom, hWndTo: HWND; var lpPoints; cPoints: UINT): Integer;
//x2nie got from https://code.google.com/p/luipack/source/browse/trunk/lclextensions/include/generic/independentfunctions.inc
var
  i: Integer;
  XOffset, YOffset: SmallInt;
  FromPoint, ToPoint: TPoint;
begin
  FromPoint := Point(0, 0);
  ToPoint := Point(0, 0);
  if hWndFrom <> 0 then
    ClientToScreen(hWndFrom, FromPoint);
  if hWndTo <> 0 then
    ClientToScreen(hWndTo, ToPoint);
  XOffset := (FromPoint.X - ToPoint.X);
  YOffset := (FromPoint.Y - ToPoint.Y);
  for i := 0 to cPoints - 1 do
  begin
    PPoint(@lpPoints)[i].x := XOffset + PPoint(@lpPoints)[i].x;
    PPoint(@lpPoints)[i].y := YOffset + PPoint(@lpPoints)[i].y;
  end;
  Result := MakeLong(XOffset, YOffset);
end;
{$ENDIF}

{$IFDEF DRAWOFFSCREENDRAGRECT}
procedure DrawDragRect (const DC: HDC; const NewRect, OldRect: PRect;
  const NewSize, OldSize: TSize; const Brush: HBRUSH; BrushLast: HBRUSH);
{ Draws a dragging outline, hiding the old one if neccessary. This is
  completely flicker free, unlike the old DrawFocusRect method. In case
  you're wondering, I got a lot of ideas from the MFC sources.

  Either NewRect or OldRect can be nil or empty. }
  function CreateNullRegion: HRGN;
  var
    R: TRect;
  begin
    SetRectEmpty (R);
    Result := CreateRectRgnIndirect(R);
  end;
var
  SaveIndex: Integer;
  rgnNew, rgnOutside, rgnInside, rgnLast, rgnUpdate: HRGN;
  R: TRect;
begin
  rgnLast := 0;
  rgnUpdate := 0;

  { First, determine the update region and select it }
  if NewRect = nil then begin
    SetRectEmpty (R);
    rgnOutside := CreateRectRgnIndirect(R);
  end
  else begin
    R := NewRect^;
    rgnOutside := CreateRectRgnIndirect(R);
    InflateRect (R, -NewSize.cx, -NewSize.cy);
    IntersectRect (R, R, NewRect^);
  end;
  rgnInside := CreateRectRgnIndirect(R);
  rgnNew := CreateNullRegion;
  CombineRgn (rgnNew, rgnOutside, rgnInside, RGN_XOR);

  if BrushLast = 0 then
    BrushLast := Brush;

  if OldRect <> nil then begin
    { Find difference between new region and old region }
    rgnLast := CreateNullRegion;
    with OldRect^ do
      SetRectRgn (rgnOutside, Left, Top, Right, Bottom);
    R := OldRect^;
    InflateRect (R, -OldSize.cx, -OldSize.cy);
    IntersectRect (R, R, OldRect^);
    SetRectRgn (rgnInside, R.Left, R.Top, R.Right, R.Bottom);
    CombineRgn (rgnLast, rgnOutside, rgnInside, RGN_XOR);

    { Only diff them if brushes are the same }
    if Brush = BrushLast then begin
      rgnUpdate := CreateNullRegion;
      CombineRgn (rgnUpdate, rgnLast, rgnNew, RGN_XOR);
    end;
  end;

  { Save the DC state so that the clipping region can be restored }
  SaveIndex := SaveDC(DC);
  try
    if (Brush <> BrushLast) and (OldRect <> nil) then begin
      { Brushes are different -- erase old region first }
      SelectClipRgn (DC, rgnLast);
      GetClipBox (DC, R);
      SelectObject (DC, BrushLast);
      PatBlt (DC, R.Left, R.Top, R.Right-R.Left, R.Bottom-R.Top, PATINVERT);
    end;

    { Draw into the update/new region }
    if rgnUpdate <> 0 then
      SelectClipRgn (DC, rgnUpdate)
    else
      SelectClipRgn (DC, rgnNew);
    GetClipBox (DC, R);
    SelectObject (DC, Brush);
    PatBlt (DC, R.Left, R.Top, R.Right-R.Left, R.Bottom-R.Top, PATINVERT);
  finally
    { Clean up DC }
    RestoreDC (DC, SaveIndex);
  end;

  { Free regions }
  if rgnNew <> 0 then DeleteObject (rgnNew);
  if rgnOutside <> 0 then DeleteObject (rgnOutside);
  if rgnInside <> 0 then DeleteObject (rgnInside);
  if rgnLast <> 0 then DeleteObject (rgnLast);
  if rgnUpdate <> 0 then DeleteObject (rgnUpdate);
end;
{$ENDIF}
  
procedure ProcessPaintMessages;
{ Dispatches all pending WM_PAINT messages. In effect, this is like an
  'UpdateWindow' on all visible windows }
var
  Msg: TMsg;
begin
{$IFNDEF FPC}
  while
    {$IFDEF FPC}
    PeekMessage(Msg, 0, LM_PAINT, LM_PAINT, PM_NOREMOVE)
    {$ELSE}
    PeekMessage(Msg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE)
    {$ENDIF}
  do begin
  //while PeekMessage(Msg, 0, WM_PAINT, WM_PAINT, PM_NOREMOVE) do begin
    case
    {$IFDEF FPC}
      Integer(GetMessage(Msg, 0, LM_PAINT, LM_PAINT))
    {$ELSE}
      Integer(GetMessage(Msg, 0, WM_PAINT, WM_PAINT))
    {$ENDIF}

      of

      -1: Break; { if GetMessage failed }
      0: begin
           { Repost WM_QUIT messages }
           PostQuitMessage (Msg.WParam);
           Break;
         end;
    end;
    DispatchMessage (Msg);
  end;
{$ENDIF}
end;
(*procedure ProcessPaintMessages;
{ Dispatches all pending WM_PAINT messages. In effect, this is like an
  'UpdateWindow' on all visible windows }
var
  AMsg: {$IFDEF FPC}{$IFDEF WINDOWS}jwawinuser.{$ELSE}LCLType.{$ENDIF}{$ENDIF}TMsg;
begin
  while PeekMessage(AMsg, 0, {$IFDEF FPC}LM_PAINT, LM_PAINT,{$ELSE}WM_PAINT, WM_PAINT,{$ENDIF} PM_NOREMOVE) do begin
   if AMsg.message = {$IFDEF FPC}LM_PAINT{$ELSE}WM_PAINT{$ENDIF} Then
//    case Integer(GetMessage(Msg, 0, {$IFDEF FPC}LM_PAINT, LM_PAINT{$ELSE}WM_PAINT, WM_PAINT{$ENDIF})) of
//      -1: Break; { if GetMessage failed }
//      0:
         begin
           // avant : postquitmessage( Msg.WParam)
           { Repost WM_QUIT messages }
           SendMessage (AMsg.WParam,{$IFDEF FPC}LM_QUIT{$ELSE}WM_QUIT{$ENDIF},0,0);
           Break;
         end;
//    end;
{$IFDEF WINDOWS}
    DispatchMessage ({$IFDEF FPC}jwawinuser.LPMsg(@Amsg){$ELSE}AMsg{$ENDIF});
{$ENDIF}
  end;
end;*)

function GetDockedCloseButtonRect (const Control: TCustomToolWindowX2;
  const LeftRight: Boolean): TRect;
var
  X, Y, Z: Integer;
begin
  Z := DragHandleSizes[Control.CloseButtonWhenDocked, Control.FDragHandleStyle] - 3;
  if not LeftRight then begin
    X := DockedBorderSize+1;
    Y := DockedBorderSize;
  end
  else begin
    X := (Control.ClientWidth + DockedBorderSize) - Z;
    Y := DockedBorderSize+1;
  end;
  Result := Bounds(X, Y, Z, Z);
end;

function GetDockTypeOf (const Control: TDockX2): TDockType;
begin
  if Control = nil then
    Result := dtNotDocked
  else begin
    if not(Control.Position in PositionLeftOrRight) then
      Result := dtTopBottom
    else
      Result := dtLeftRight;
  end;
end;
function GetToolWindowParentForm (const ToolWindow: TCustomToolWindowX2):
  {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm .$ENDIF};
var
  Ctl: TWinControl;
begin
  Result := nil;
  Ctl := ToolWindow;
  while Assigned(Ctl.Parent) do begin
    if Ctl.Parent is {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF} then
      Result := {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF}(Ctl.Parent);
    Ctl := Ctl.Parent;
  end;
  { ^ for compatibility with ActiveX controls, that code is used instead of
    GetParentForm because it returns nil unless the form is the *topmost*
    parent }
  if Result is TFloatingWindowParent then
    Result := TFloatingWindowParent(Result).ParentForm;
end;

function ValidToolWindowParentForm (const ToolWindow: TCustomToolWindowX2):
  {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm $ENDIF};
begin
  Result := GetToolWindowParentForm(ToolWindow);
  if Result = nil then
    raise EInvalidOperation.{$IFDEF TB97D3}CreateFmt{$ELSE}CreateResFmt{$ENDIF}
      ('SParentRequired', [ToolWindow.Name]);
end;

function GetSmallCaptionHeight: Integer;
{ Returns height of the caption of a small window }
begin
  if NewStyleControls then
    Result := GetSystemMetrics(SM_CYSMCAPTION)
  else
    { Win 3.x doesn't support small captions, so, like Office 97, use the size
      of normal captions minus one }
    Result := GetSystemMetrics(SM_CYCAPTION) - 1;
end;

{$IFNDEF FPC}
function GetPrimaryDesktopArea: TRect;
{ Returns a rectangle containing the "work area" of the primary display
  monitor, which is the area not taken up by the taskbar. }
begin
  if not SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0) then
    { SPI_GETWORKAREA is only supported by Win95 and NT 4.0. So it fails under
      Win 3.x. In that case, return a rectangle of the entire screen }
    Result := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN),
      GetSystemMetrics(SM_CYSCREEN));
end;

function UsingMultipleMonitors: Boolean;
{ Returns True if the system has more than one display monitor configured. }
var
  NumMonitors: Integer;
begin
  NumMonitors := GetSystemMetrics(80 {SM_CMONITORS});
  Result := (NumMonitors <> 0) and (NumMonitors <> 1);
  { ^ NumMonitors will be zero if not running Win98, NT 5, or later }
end;

type
  HMONITOR = type Integer;
  PMonitorInfoA = ^TMonitorInfoA;
  TMonitorInfoA = record
    cbSize: DWORD;
    rcMonitor: TRect;
    rcWork: TRect;
    dwFlags: DWORD;
  end;
const
  MONITOR_DEFAULTTONEAREST = $2;
type
  TMultiMonApis = record
    funcMonitorFromRect: function(lprcScreenCoords: PRect; dwFlags: DWORD): HMONITOR; stdcall;
    funcMonitorFromPoint: function(ptScreenCoords: TPoint; dwFlags: DWORD): HMONITOR; stdcall;
    funcGetMonitorInfoA: function(hMonitor: HMONITOR; lpMonitorInfo: PMonitorInfoA): BOOL; stdcall;
  end;

{ Under D4 I could be using the MultiMon unit for the multiple monitor
  function imports, but its stubs for MonitorFromRect and MonitorFromPoint
  are seriously bugged... So I chose to avoid the MultiMon unit entirely. }

function InitMultiMonApis (var Apis: TMultiMonApis): Boolean;
var
  User32Handle: THandle;
begin
  User32Handle := GetModuleHandle(user32);
  Apis.funcMonitorFromRect := GetProcAddress(User32Handle, 'MonitorFromRect');
  Apis.funcMonitorFromPoint := GetProcAddress(User32Handle, 'MonitorFromPoint');
  Apis.funcGetMonitorInfoA := GetProcAddress(User32Handle, 'GetMonitorInfoA');
  Result := Assigned(Apis.funcMonitorFromRect) and
    Assigned(Apis.funcMonitorFromPoint) and Assigned(Apis.funcGetMonitorInfoA);
end;

function GetDesktopAreaOfMonitorContainingRect2 (const R: TRect): TRect;
{ Returns the work area of the monitor which the rectangle R intersects with
  the most, or the monitor nearest R if no monitors intersect. }
var
  Apis: TMultiMonApis;
  M: HMONITOR;
  MonitorInfo: TMonitorInfoA;
begin
  if UsingMultipleMonitors and InitMultiMonApis(Apis) then begin
    M := Apis.funcMonitorFromRect(@R, MONITOR_DEFAULTTONEAREST);
    MonitorInfo.cbSize := SizeOf(MonitorInfo);
    if Apis.funcGetMonitorInfoA(M, @MonitorInfo) then begin
      Result := MonitorInfo.rcWork;
      Exit;
    end;
  end;
  Result := GetPrimaryDesktopArea;
end;
function GetDesktopAreaOfMonitorContainingPoint0 (const P: TPoint): TRect;
{ Returns the work area of the monitor containing the point P, or the monitor
  nearest P if P isn't in any monitor's work area. }
var
  Apis: TMultiMonApis;
  M: HMONITOR;
  MonitorInfo: TMonitorInfoA;
  mon : TMonitor;
begin
  {$IFNDEF FPC}
  if UsingMultipleMonitors and InitMultiMonApis(Apis) then begin
    M := Apis.funcMonitorFromPoint(P, MONITOR_DEFAULTTONEAREST);
    MonitorInfo.cbSize := SizeOf(MonitorInfo);
    if Apis.funcGetMonitorInfoA(M, @MonitorInfo) then begin
      Result := MonitorInfo.rcWork;
      Exit;
    end;
  end;
  {$ENDIF}
  Result := GetPrimaryDesktopArea;
end;
{$ENDIF}

function GetDesktopAreaOfMonitorContainingRect (const R: TRect): TRect;
{ Returns the work area of the monitor which the rectangle R intersects with
  the most, or the monitor nearest R if no monitors intersect. }
begin
  Result := Screen.MonitorFromRect(R).WorkareaRect;
end;

function GetDesktopAreaOfMonitorContainingPoint (const P: TPoint): TRect;
{ Returns the work area of the monitor containing the point P, or the monitor
  nearest P if P isn't in any monitor's work area. }
begin
  Result := Screen.MonitorFromPoint(P).WorkareaRect;
end;

{ TDockX2 }

function CompareDockRowPos (const Item1, Item2, ExtraData: Pointer): Integer; far;
begin
  if TCustomToolWindowX2(Item1).FDockRow <> TCustomToolWindowX2(Item2).FDockRow then
    Result := TCustomToolWindowX2(Item1).FDockRow - TCustomToolWindowX2(Item2).FDockRow
  else
    Result := TCustomToolWindowX2(Item1).FDockPos - TCustomToolWindowX2(Item2).FDockPos;
end;

procedure TDockX2.AlignControls(AControl: TControl; var Rect: TRect);
begin
  ArrangeToolbars (False);
end;

procedure TDockX2.ArrangeToolbars(const ClipPoses: Boolean);
{ The main procedure to arrange all the toolbars docked to it }
type
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array[0..$7FFFFFFF div SizeOf(Integer)-1] of Integer;
var
  LeftRight: Boolean;
  EmptySize: Integer;
  HighestRow,
  LCurrentRow, CurDockPos,
  CurRowPixel, I, J, K, ClientW, ClientH: Integer;
  CurRowSize: Integer;
  CurBarSize: Integer;
  T: TCustomToolWindowX2;
  NewDockPos: PIntegerArray;
  MultiRow : TList;

  procedure ArrangeNoOverlaped(FirstRow, LastRow: Integer; UntilBar:Integer = -1);
  { Adjust DockPos's of toolbars to make sure none of the them overlap }
  var
    LCurrentRow,I,J,K,Z: Integer;
    M,T: TCustomToolWindowX2;
  begin
    //for LCurrentRow := 0 to HighestRow do begin
    for LCurrentRow := FirstRow to LastRow do begin
      CurDockPos := 0;
      Z := DockList.Count-1;
      if (LCurrentRow = LastRow) and (UntilBar > -1) then
        Z := UntilBar;
      for I := 0 to Z do begin
        T := TCustomToolWindowX2(DockList[I]);
        with T do
          if ((FDockRow = LCurrentRow)
          //or ( (RowsMin > 1) and (LCurrentRow >= FDockRow) and (LCurrentRow <= FDockRow + RowsMin - 1  ) )
          ) and ToolbarVisibleOnDock(T) then begin
            if FullSize then
              FDockPos := 0
            else begin
              {if FDockPos <= CurDockPos then
                FDockPos := CurDockPos
              else
                CurDockPos := FDockPos;}
              if FDockPos > CurDockPos then
                CurDockPos := FDockPos //increase value for next bar's position
              else
                FDockPos := CurDockPos; //Shift to right avoiding overlap

              {if not LeftRight then
                Inc (CurDockPos, Width)
              else
                Inc (CurDockPos, Height);}
              Inc( CurDockPos, Weight);

              {spare space for multirow bar}
              if MultiRow.Count > 0 then
              begin
                for J := 0 to MultiRow.Count-1 do
                begin
                  M := TCustomToolWindowX2(MultiRow[J]);
                  if M = T then Continue;
                  if (LCurrentRow > M.FDockRow)
                    and (LCurrentRow <= M.FDockRow + M.RowsMin - 1  )

                    and (CurDockPos > M.FDockPos)
                    and (CurDockPos < M.FDockPos + M.Weight  )
                     then
                  begin
                    //move the multi row to right; avoid overlap
                    M.FDockPos := CurDockPos;
                    K := DockList.IndexOf(M) -1; //before M
                    if K < 0 then K := 0;
                    ArrangeNoOverlaped(M.FDockRow, LCurrentRow, K); //recalculate from this multirow-bar.
                    Inc(CurDockPos, M.Weight); //CurDockPos := M.FDockPos + M.Width;
                    //T.FDockPos := CurDockPos;
                  end;
                end;
              end;

            end;
          end;
      end;
    end;

  end;

  procedure ArrangeCompacting(FirstRow, LastRow : Integer; Block :Integer = -1;
    UntilBar:Integer = -1);
  var
    LCurrentRow,CurDockPos,
    I,J,K,Z: Integer;
    M,T: TCustomToolWindowX2;
    
      procedure CompactFromRight(FirstBar,LastBar: Integer);
      var
        CurDockPos,
        I,J,K,Z: Integer;
        M,T: TCustomToolWindowX2;
      begin
        if not LeftRight then
          CurDockPos := ClientW
        else
          CurDockPos := ClientH;
        //for I := DockList.Count-1 downto 0 do begin
        for I := FirstBar downto LastBar do begin
          T := TCustomToolWindowX2(DockList[I]);
          with T do
            if ((FDockRow = LCurrentRow)
            //or ((RowsMin > 1) and (LCurrentRow >= FDockRow) and ( LCurrentRow <= FDockRow + RowsMin - 1  ) )
            ) and ToolbarVisibleOnDock(T) and not FullSize then
            begin
              Dec( CurDockPos, Weight);

              if NewDockPos[I] > CurDockPos then
                NewDockPos[I] := CurDockPos;
              CurDockPos := NewDockPos[I];

              if (Block = 1) and (Z = I) then
                Exit;

              {spare space for multirow bar}
              if MultiRow.Count > 0 then
              begin
                for J := MultiRow.Count-1 downto 0 do
                begin
                  M := TCustomToolWindowX2(MultiRow[J]);
                  if M = T then Continue;
                  K := DockList.IndexOf(M); //index for NewDocPos
                  if K > I then Continue; //not ready?

                  if (LCurrentRow > M.FDockRow)
                    and (LCurrentRow <= M.FDockRow + M.RowsMin - 1  )

                    and (NewDockPos[K] + M.Weight > CurDockPos) //nrabas
                    and (NewDockPos[K] < CurDockPos)
                    //and (CurDockPos <= M.FDockPos)
                    //and (CurDockPos + T.Width > M.FDockPos)
                  then
                  begin
                    Dec(CurDockPos, M.Width);
                    NewDockPos[K] := CurDockPos;

                    Dec(K); //before bar
                    if K < 0 then K := 0;
                    //ArrangeCompacting(M.FDockRow, LCurrentRow, 1, K); //recalculate from this multirow-bar.
                    CompactFromRight(FirstBar,I);

                  end;
                end;
              end;
            end;
        end;
      end;

      procedure CompactFromLeft(FirstBar,LastBar: Integer);
      var
        CurDockPos,
        I,J,K,Z: Integer;
        M,T: TCustomToolWindowX2;
      begin
        CurDockPos := 0;
        //for I := 0 to DockList.Count-1 do begin
        for I := FirstBar to LastBar do begin
          T := TCustomToolWindowX2(DockList[I]);
          with T do
            if ((FDockRow = LCurrentRow)
            //or ((RowsMin > 1) and (LCurrentRow >= FDockRow) and ( LCurrentRow <= FDockRow + RowsMin - 1  ) )
            )and ToolbarVisibleOnDock(T) and not FullSize then begin
              if NewDockPos[I] <= CurDockPos then
                NewDockPos[I] := CurDockPos
              else
                CurDockPos := NewDockPos[I];

              Inc( CurDockPos, Weight);

              if (Block = 2) and (Z = I) then
                Exit;
              {spare space for multirow bar}
              if MultiRow.Count > 0 then
              begin
                for J := 0 to MultiRow.Count-1 do
                begin
                  M := TCustomToolWindowX2(MultiRow[J]);
                  K := DockList.IndexOf(M); //index for NewDocPos
                  if M = T then Continue;
                  if (LCurrentRow > M.FDockRow)
                    and (LCurrentRow <= M.FDockRow + M.RowsMin - 1  )

                    and (CurDockPos > NewDockPos[K])
                    and (CurDockPos < NewDockPos[K] + M.Weight  )
                     then
                  begin
                    //move the multi row to right; avoid overlap
                    NewDockPos[K] := CurDockPos;
                    Inc(CurDockPos, M.Weight); //CurDockPos := M.FDockPos + M.Width;
                    Dec(K); //before M
                    if K < 0 then K := 0;
                    //ArrangeCompacting(M.FDockRow, LCurrentRow, 2, K); //recalculate from this multirow-bar.
                    //T.FDockPos := CurDockPos;
                    CompactFromLeft(FirstBar, I);
                  end;
                end;
              end;

              {spare space for multirow bar}
              {if MultiRow.Count > 0 then
              begin
                for J := 0 to MultiRow.Count-1 do
                begin
                  M := TCustomToolWindowX2(MultiRow[J]);
                  if M = T then Continue;
                  if (LCurrentRow > M.FDockRow)
                    and (LCurrentRow <= M.FDockRow + M.RowsMin - 1  )

                    and (T.FDockPos <= M.FDockPos)
                    and (T.FDockPos + T.Width > M.FDockPos)
                     then
                  begin
                    CurDockPos := M.FDockPos + M.Width;
                    T.FDockPos := CurDockPos;
                  end;
                end;
              end;}

            end;
        end;

      end;


  begin
    //for LCurrentRow := 0 to HighestRow do
    for LCurrentRow := FirstRow to LastRow do
    begin

      Z := 0;
      if (LCurrentRow = LastRow) and (UntilBar > -1) then
        Z := UntilBar;

      //for I := DockList.Count-1 downto 0 do begin
      CompactFromRight(DockList.Count-1, 0);

      { Since the above code will make the toolbars go off the left if the
        width of all toolbars is more than the width of the dock, push them
        back right if needed }
      CompactFromLeft(0, DockList.Count-1);
    end;
  end;


begin
  if ClipPoses then
    FArrangeToolbarsClipPoses := True;
  if (FDisableArrangeToolbars > 0) or (csLoading in ComponentState) then begin
    FArrangeToolbarsNeeded := True;
    Exit;
  end;

  Inc (FDisableArrangeToolbars);
  MultiRow := TList.Create;
  try
    { Work around VCL alignment bug when docking toolbars taller or wider than
      the client height or width of the form. }
    if not(csDesigning in ComponentState) and HandleAllocated then
      SetWindowPos (Handle, HWND_TOP, 0, 0, 0, 0,
        SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);

    LeftRight := Position in PositionLeftOrRight;

    if not HasVisibleToolbars then begin
      EmptySize := Ord(FFixAlign);
      if csDesigning in ComponentState then
        EmptySize := 9;
      if not LeftRight then
        ChangeWidthHeight (Width, EmptySize)
      else
        ChangeWidthHeight (EmptySize, Height);
      Exit;
    end;

    { It can't read the ClientWidth and ClientHeight properties because they
      attempt to create a handle, which requires Parent to be set. "ClientW"
      and "ClientH" are calculated instead. }
    //ClientW := Width - FNonClientWidth;
    ClientW := ClientWidth;
    if ClientW < 0 then ClientW := 0;
    //ClientH := Height - FNonClientHeight;
    ClientH := ClientHeight;
    if ClientH < 0 then ClientH := 0;

    { If LimitToOneRow is True, only use the first row }
    if FLimitToOneRow then
      for I := 0 to DockList.Count-1 do
        with TCustomToolWindowX2(DockList[I]) do
          FDockRow := 0;
    { Remove any blank rows }
    RemoveBlankRows;

    { Ensure DockList is in correct ordering according to DockRow/DockPos }
    ListSortEx (DockList, CompareDockRowPos, nil);
    ListSortEx (DockVisibleList, CompareDockRowPos, nil);
    { Find highest row number }
    HighestRow := GetHighestRow;

    { Find FullSize toolbars and make sure there aren't any other toolbars
      on the same row. If there are, shift them down a row. }
    LCurrentRow := 0;
    while LCurrentRow <= HighestRow do begin
      for I := 0 to DockList.Count-1 do
        with TCustomToolWindowX2(DockList[I]) do
          if (FDockRow = LCurrentRow) and FullSize then
            for J := 0 to DockList.Count-1 do
              if (J <> I) and (TCustomToolWindowX2(DockList[J]).FDockRow = LCurrentRow) then begin
                for K := 0 to DockList.Count-1 do
                  with TCustomToolWindowX2(DockList[K]) do
                    if (K <> I) and (FDockRow >= LCurrentRow) then begin
                      Inc (FDockRow);
                      if FDockRow > HighestRow then
                        HighestRow := FDockRow;
                    end;
                Break;
              end;
      Inc (LCurrentRow);
    end;

    for K := 0 to DockList.Count-1 do
      with TCustomToolWindowX2(DockList[K]) do
        if RowsMin > 1 then
          MultiRow.Add(DockList[K]);


    { Rebuild the RowInfo, since rows numbers may have shifted }
    BuildRowInfo;
    HighestRow := RowSizes.Count-1;

    { Adjust DockPos's of toolbars to make sure none of the them overlap }
    ArrangeNoOverlaped(0, HighestRow);
    
    { Create a temporary array that holds new DockPos's for the toolbars }
    GetMem (NewDockPos, DockList.Count * SizeOf(Integer));
    try
      for I := 0 to DockList.Count-1 do
        NewDockPos[I] := TCustomToolWindowX2(DockList[I]).FDockPos;

      { Move toolbars (to left) that go off the edge of the dock to a fully visible
        position if possible }
      ArrangeCompacting(0, HighestRow);

      { If FArrangeToolbarsClipPoses (ClipPoses) is True, update all the
        toolbars' DockPos's to match the actual positions }
      if FArrangeToolbarsClipPoses then
        for I := 0 to DockList.Count-1 do
          TCustomToolWindowX2(DockList[I]).FDockPos := NewDockPos[I];

      { Now actually move the toolbars }
      CurRowPixel := 0;
      for LCurrentRow := 0 to HighestRow do begin
        CurRowSize := Longint(RowSizes[LCurrentRow]);
        if CurRowSize <> 0 then
          Inc (CurRowSize, DockedBorderSize2);
        for I := 0 to DockList.Count-1 do begin
          T := TCustomToolWindowX2(DockList[I]);
          with T do
            if (FDockRow = LCurrentRow)
            and ToolbarVisibleOnDock(T) then begin
              DisableAutoSizing;
              try
                if not LeftRight then begin
                  J := Width;
                  if FullSize then J := ClientW;

                  //SetBounds (NewDockPos[I], CurRowPixel, J, CurRowSize);
                  CurBarSize := CurRowSize;
                  if T.RowsMin > 1 then
                  begin
                    for K := 1 to T.RowsMin -1 do
                    begin
                      CurBarSize := CurBarSize + Longint(RowSizes[LCurrentRow+K]) + DockedBorderSize2;
                    end;
                  end;
                  SetBounds (NewDockPos[I], CurRowPixel, J, CurBarSize);
                end
                else begin
                  J := Height;
                  if FullSize then J := ClientH;
                  //SetBounds (CurRowPixel, NewDockPos[I], CurRowSize, J);
                  CurBarSize := CurRowSize;
                  if T.RowsMin > 1 then
                  begin
                    for K := 1 to T.RowsMin -1 do
                    begin
                      CurBarSize := CurBarSize + Longint(RowSizes[LCurrentRow+K]) + DockedBorderSize2;
                    end;
                  end;
                  SetBounds (CurRowPixel, NewDockPos[I], CurBarSize, J);
                end;
              finally
                EnableAutoSizing;
              end;
            end;
        end;
        Inc (CurRowPixel, CurRowSize);
      end;
    finally
      FreeMem (NewDockPos);
    end;

    { Set the size of the dock }
    if not LeftRight then
      ChangeWidthHeight (Width, CurRowPixel {+ FNonClientHeight})
    else
      ChangeWidthHeight (CurRowPixel {+ FNonClientWidth}, Height);
  finally
    MultiRow.Free;
    Dec (FDisableArrangeToolbars);
    FArrangeToolbarsNeeded := False;
    FArrangeToolbarsClipPoses := False;
  end;

end;

procedure TDockX2.BeginUpdate;
begin
  Inc (FDisableArrangeToolbars);
end;

procedure TDockX2.BuildRowInfo;
var
  R, I, Size, HighestSize: Integer;
  ToolbarOnRow: Boolean;
  T: TCustomToolWindowX2;
begin
  RowSizes.Clear;
  for R := 0 to GetHighestRow do begin
    ToolbarOnRow := False;
    HighestSize := 0;
    for I := 0 to DockList.Count-1 do begin
      T := TCustomToolWindowX2(DockList[I]);
      with T do
        if (FDockRow = R) and ToolbarVisibleOnDock(T) then begin
          ToolbarOnRow := True;
          GetBarSize (Size, GetDockTypeOf(Self));
          if Size > HighestSize then HighestSize := Size;
        end;
    end;
    if ToolbarOnRow and (HighestSize < DefaultBarWidthHeight) then
      HighestSize := DefaultBarWidthHeight;
    RowSizes.Add (Pointer(HighestSize));
  end;

end;

procedure TDockX2.ChangeDockList(const Insert: Boolean;
  const Bar: TCustomToolWindowX2);
{ Inserts or removes Bar from DockList }
var
  I: Integer;
begin
  I := DockList.IndexOf(Bar);
  if Insert then begin
    if I = -1 then begin
      Bar.FreeNotification (Self);
      DockList.Add (Bar);
    end;
  end
  else begin
    if I <> -1 then
      DockList.Delete (I);
  end;
  ToolbarVisibilityChanged (Bar, False);
end;

procedure TDockX2.ChangeWidthHeight(const NewWidth, NewHeight: Integer);
{ Same as setting Width/Height directly, but does not lose Align position. }
begin
  case Align of
    alTop, alLeft:
      SetBounds (Left, Top, NewWidth, NewHeight);
    alBottom:
      SetBounds (Left, Top-NewHeight+Height, NewWidth, NewHeight);
    alRight:
      SetBounds (Left-NewWidth+Width, Top, NewWidth, NewHeight);
  end;
end;

constructor TDockX2.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls] -
    [csClickEvents, csCaptureMouse, csOpaque];
  FAllowDrag := True;
  //FBkgOnToolbars := True;
  DockList := TList.Create;
  DockVisibleList := TList.Create;
  RowSizes := TList.Create;

  Color := clBtnFace;
  Position := dpTop;

  {$IFNDEF TBX2_DRAGDROP}
  self.DockSite := True;
  {$ENDIF}
end;

{$IFNDEF TBX2_DRAGDROP}
procedure TDockX2.DoDockOver(Source: TDragDockObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited;
  Accept := True;
end;
{$ENDIF}

{$IFDEF TBX2_GR32}
procedure TDockX2.DoPaintBuffer;
var
  R, R2: TRect;
  P1, P2: TPoint;
begin
  inherited;
  Buffer.Clear(Color32(self.Color));
  with Buffer.Canvas do begin
    R := ClientRect;

    { Draw dotted border in design mode }
    if csDesigning in ComponentState then begin
      Pen.Style := psDot;
      Pen.Color := clBtnShadow;
      Brush.Style := bsClear;
      Rectangle (R.Left, R.Top, R.Right, R.Bottom);
      Pen.Style := psSolid;
      InflateRect (R, -1, -1);
    end;
end;
{$ELSE}
procedure TDockX2.Paint;
var
  R, R2: TRect;
  P1, P2: TPoint;
begin
  inherited;
  //Buffer.Clear(Color32(self.Color));
  with Canvas do begin
    R := ClientRect;

    { Draw dotted border in design mode }
    if csDesigning in ComponentState then begin
      Pen.Style := psDot;
      Pen.Color := clBtnShadow;
      Brush.Style := bsClear;
      Rectangle (R.Left, R.Top, R.Right, R.Bottom);
      Pen.Style := psSolid;
      InflateRect (R, -1, -1);
    end;

    { Draw the Background }
    {if UsingBackground then begin
      R2 := ClientRect;
      // Make up for nonclient area
      P1 := ClientToScreen(Point(0, 0));
      P2 := Parent.ClientToScreen(BoundsRect.TopLeft);
      Dec (R2.Left, Left + (P1.X-P2.X));
      Dec (R2.Top, Top + (P1.Y-P2.Y));
      DrawBackground (Canvas.Handle, R, nil, R2);
    end;}
  end;
end;
{$ENDIF}


procedure TDockX2.EndUpdate;
begin
  Dec (FDisableArrangeToolbars);
  if FArrangeToolbarsNeeded and (FDisableArrangeToolbars = 0) then
    ArrangeToolbars (FArrangeToolbarsClipPoses);
end;

function TDockX2.GetDesignModeRowOf(const XY: Integer): Integer;
{ Similar to GetRowOf, but is a little different to accomidate design mode
  better }
var
  HighestRowPlus1, R, CurY, CurRowSize: Integer;
begin
  Result := 0;
  HighestRowPlus1 := GetHighestRow+1;
  CurY := 0;
  for R := 0 to HighestRowPlus1 do begin
    Result := R;
    if R = HighestRowPlus1 then Break;
    CurRowSize := GetRowSize(R, nil);
    if CurRowSize = 0 then Continue;
    Inc (CurY, CurRowSize + DockedBorderSize2);
    if XY < CurY then
      Break;
  end;

end;

function TDockX2.GetHighestRow: Integer;
{ Returns highest used row number, or -1 if no rows are used }
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DockList.Count-1 do
    with TCustomToolWindowX2(DockList[I]) do
    begin
      if (FDockRow > Result)
      then
        Result := FDockRow;

      if (RowsMin > 1) and (FDockRow + RowsMin -1 > Result)  then
          Result := FDockRow + RowsMin -1;
    end;
end;

function TDockX2.GetNumberOfToolbarsOnRow(const Row: Integer;
  const NotIncluding: TCustomToolWindowX2): Integer;
{ Returns number of toolbars on the specified row. The toolbar specified by
  "NotIncluding" is not included in the count. }
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to DockList.Count-1 do
    if (TCustomToolWindowX2(DockList[I]).FDockRow = Row) and
       (DockList[I] <> NotIncluding) then
      Inc (Result);
end;

function TDockX2.GetRowOf(const XY: Integer; var Before: Boolean): Integer;
{ Returns row number of the specified coordinate. Before is set to True if it
  was close to being in between two rows. }
var
  HighestRow, R, CurY, NextY, CurRowSize: Integer;
begin
  Result := 0;  Before := False;
  HighestRow := GetHighestRow;
  CurY := 0;
  for R := 0 to HighestRow+1 do begin
    NextY := High(NextY);
    if R <= HighestRow then begin
      CurRowSize := GetRowSize(R, nil);
      if CurRowSize = 0 then Continue;
      NextY := CurY + CurRowSize + DockedBorderSize2;
    end;
    if XY < CurY+5 then begin
      Result := R;
      Before := True;
      Break;
    end;
    if (XY >= CurY+5) and (XY < NextY-5) then begin
      Result := R;
      Break;
    end;
    CurY := NextY;
  end;
end;

function TDockX2.GetRowSize(const Row: Integer;
  const DefaultToolbar: TCustomToolWindowX2): Integer;
begin
  Result := 0;
  if Row < RowSizes.Count then
    Result := Longint(RowSizes[Row]);
  if (Result = 0) and Assigned(DefaultToolbar) then
    DefaultToolbar.GetBarSize (Result, GetDockTypeOf(Self));
end;

function TDockX2.HasVisibleToolbars: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to DockList.Count-1 do
    if ToolbarVisibleOnDock(TCustomToolWindowX2(DockList[I])) then begin
      Result := True;
      Break;
    end;
end;

procedure TDockX2.InsertRowBefore(const BeforeRow: Integer);
{ Inserts a blank row before BeforeRow, adjusting all the docked toolbars'
  FDockRow as needed }
var
  I: Integer;
begin
  for I := 0 to DockList.Count-1 do
    with TCustomToolWindowX2(DockList[I]) do
      if FDockRow >= BeforeRow then
        Inc (FDockRow);
end;

procedure TDockX2.Loaded;
begin
  inherited;
  { Rearranging is disabled while the component is loading, so now that it's
    loaded, rearrange it. }
  ArrangeToolbars (False);

end;

procedure TDockX2.RemoveBlankRows;
{ Deletes any blank row numbers, adjusting the docked toolbars' FDockRow as
  needed }
var
  HighestRow, R, I: Integer;
  RowIsEmpty: Boolean;
begin
  HighestRow := GetHighestRow;
  R := 0;
  while R <= HighestRow do begin
    RowIsEmpty := True;
    for I := 0 to DockList.Count-1 do
      with TCustomToolWindowX2(DockList[I]) do
      if (FDockRow = R)
      or ( (RowsMin > 1) and (R >= FDockRow) and (R <= FDockRow + RowsMin -1 ) ) 
      then begin
        RowIsEmpty := False;
        Break;
      end;


    if RowIsEmpty then begin
      { Shift all ones higher than R back one }
      for I := 0 to DockList.Count-1 do
        with TCustomToolWindowX2(DockList[I]) do
          if FDockRow > R then
            Dec (FDockRow);
      Dec (HighestRow);
    end
    else
      Inc (R);
  end;

end;

procedure TDockX2.SetFixAlign(const Value: Boolean);
begin
  if FFixAlign <> Value then begin
    FFixAlign := Value;
    ArrangeToolbars (False);
  end;
end;

procedure TDockX2.SetPosition(const Value: TDockPosition);
begin
  if (FPosition <> Value) and (ControlCount <> 0) then
    raise EInvalidOperation.Create(STBx2DockCannotChangePosition);
  FPosition := Value;
  case Position of
    dpTop: Align := alTop;
    dpBottom: Align := alBottom;
    dpLeft: Align := alLeft;
    dpRight: Align := alRight;
  end;
end;

procedure TDockX2.ToolbarVisibilityChanged(const Bar: TCustomToolWindowX2;
  const ForceRemove: Boolean);
var
  Modified, VisibleOnDock: Boolean;
  I: Integer;
begin
  Modified := False;
  I := DockVisibleList.IndexOf(Bar);
  VisibleOnDock := not ForceRemove and ToolbarVisibleOnDock(Bar);
  if VisibleOnDock then begin
    if I = -1 then begin
      DockVisibleList.Add (Bar);
      Modified := True;
    end;
  end
  else begin
    if I <> -1 then begin
      DockVisibleList.Remove (Bar);
      Modified := True;
    end;
  end;

  if Modified then begin
    ArrangeToolbars (False);

    if Assigned(FOnInsertRemoveBar) then
      FOnInsertRemoveBar (Self, VisibleOnDock, Bar);
  end;
end;

function TDockX2.ToolbarVisibleOnDock(
  const AToolbar: TCustomToolWindowX2): Boolean;
begin
  Result := (AToolbar.Parent = Self) and
    (AToolbar.Visible or (csDesigning in AToolbar.ComponentState));
end;

{ TCustomToolWindowX2 }

procedure TCustomToolWindowX2.ArrangeControls;
begin
  if not (csLoading in ComponentState) then
  CustomArrangeControls (GetDockTypeOf(DockedTo), DockedTo, True);
end;

procedure TCustomToolWindowX2.BeginUpdate;
begin
  Inc (FDisableArrangeControls);
end;

procedure TCustomToolWindowX2.CustomArrangeControls(
  const PreviousDockType: TDockType; const DockingTo: TDockX2;
  const Resize: Boolean);
var
  WH: Integer;
  Size: TPoint;
begin
  if (FDisableArrangeControls > 0) or
     { Prevent flicker while loading or destroying }
     (csLoading in ComponentState) or
     { This will not work if it's destroying }
     (csDestroying in ComponentState) or
     (Parent = nil) or
     (Parent.HandleAllocated and (csDestroying in Parent.ComponentState)) then
  begin
    FArrangeNeeded := True;
    Exit;
  end;

  FArrangeNeeded := False;

  Inc (FDisableArrangeControls);
  try
    Size := OrderControls(True, PreviousDockType, DockingTo);
    with Size do
      if Resize then begin
        if Docked then begin
          GetDockRowSize (WH);
          if not(DockedTo.Position in PositionLeftOrRight) then begin
            if WH > Y then Y := WH;
            if FullSize then
              X := (DockedTo.Width{-DockedTo.NonClientWidth}) - FNonClientWidth;
              //X := DockedTo.ClientWidth;
          end
          else begin
            if WH > X then X := WH;
            if FullSize then
              Y := (DockedTo.Height{-DockedTo.NonClientHeight}) - FNonClientHeight;
              //Y := DockedTo.ClientHeight;
          end;
        end;
        Inc (X, FNonClientWidth);
        Inc (Y, FNonClientHeight);
        if (Width <> X) or (Height <> Y) then begin
          { ////
          DisableAutoSizing;
          try
            SetBounds (Left, Top, X, Y);
          finally
            EnableAutoSizing;
          end;}
        end;
      end;
  finally
    Dec (FDisableArrangeControls);
  end;

end;

procedure TCustomToolWindowX2.DoDockChangingHidden(DockingTo: TDockX2);
begin
  if not(csDestroying in ComponentState) and Assigned(FOnDockChangingHidden) then
    FOnDockChangingHidden (Self, DockingTo);
end;

procedure TCustomToolWindowX2.DoMove;
begin
  if Assigned(FOnMove) then
    FOnMove (Self);
end;
{$IFDEF TBX2_GR32}
procedure TCustomToolWindowX2.DoPaintBuffer;
begin
  inherited;
  Buffer.Clear(Color32(Self.Color));
  DrawDockedNCArea;
end;
{$else}
procedure TCustomToolWindowX2.Paint;
begin
  inherited;
  //Buffer.Clear(Color32(Self.Color));
  DrawDockedNCArea;
end;
{$ENDIF}

procedure TCustomToolWindowX2.DrawDockedNCArea;
{ Redraws all the non-client area of the toolbar when it is docked. }
var
  DC: HDC;
  R: TRect;
  DockType: TDockType;
  X, Y, Y2, Y3, S, SaveIndex: Integer;
  R2, R3, R4: TRect;
  P1, P2: TPoint;
  Brush: HBRUSH;
  Clr: TColorRef;
  UsingBackground, B: Boolean;

  procedure DrawRaisedEdge (R: TRect; const FillInterior: Boolean);
  const
    FillMiddle: array[Boolean] of UINT = (0, BF_MIDDLE);
  begin
    DrawEdge (DC, R, BDR_RAISEDINNER, BF_RECT or FillMiddle[FillInterior]);
  end;

const
  CloseButtonState: array[Boolean] of UINT = (0, DFCS_PUSHED);
begin
  //if not DrawToDC then ValidateDockedNCArea;
  if not Docked or not HandleAllocated then Exit;
{$IFNDEF FPC}
  {if not DrawToDC then
    DC := GetWindowDC(Handle)
  else}
{$ENDIF}
    //DC := ADC;
    {$IFDEF TBX2_GR32}
    DC := Buffer.Canvas.Handle;
    {$ELSE}
    DC := Canvas.Handle;
    {$ENDIF}

  try
    { Use update region }
    //if not DrawToDC then  SelectNCUpdateRgn (Handle, DC, Clip);

    //x2nie avoid windows only. so we use both lazarus & delphi
    R := Rect(0, 0, Width, Height);

    { This works around WM_NCPAINT problem described at top of source code }
    {no!  R := Rect(0, 0, Width, Height);}
    //GetWindowRect (Handle, R); OffsetRect (R, -R.Left, -R.Top);


    if not(DockedTo.Position in PositionLeftOrRight) then
      DockType := dtTopBottom
    else
      DockType := dtLeftRight;

    Brush := CreateSolidBrush(ColorToRGB(Color));

    //UsingBackground := DockedTo.UsingBackground and DockedTo.FBkgOnToolbars;

    { Border }
    if BorderStyle = bsSingle then
      DrawRaisedEdge (R, False);
    //else
      //FrameRect (DC, R, Brush);
    R2 := R;
    InflateRect (R2, -1, -1);
    if not UsingBackground then
      FrameRect (DC, R2, Brush);

    { Draw the Background }
    {if UsingBackground then begin
      R2 := R;
      P1 := DockedTo.ClientToScreen(Point(0, 0));
      P2 := DockedTo.Parent.ClientToScreen(DockedTo.BoundsRect.TopLeft);
      Dec (R2.Left, Left + DockedTo.Left + (P1.X-P2.X));
      Dec (R2.Top, Top + DockedTo.Top + (P1.Y-P2.Y));
      InflateRect (R, -1, -1);
      GetWindowRect (Handle, R4);
      R3 := ClientRect;
      with ClientToScreen(Point(0, 0)) do
        OffsetRect (R3, X-R4.Left, Y-R4.Top);
      DockedTo.DrawBackground (DC, R, @R3, R2);
    end;}

    { The drag handle at the left, or top }
    if DockedTo.FAllowDrag then begin
      SaveIndex := SaveDC(DC);
      if DockType <> dtLeftRight then
        Y2 := ClientHeight
      else
        Y2 := ClientWidth;
      //Inc (Y2, DockedBorderSize);
      Y3 := Y2;
      S := DragHandleSizes[FCloseButtonWhenDocked, FDragHandleStyle];
      if FDragHandleStyle <> dhNone then begin
        X := DockedBorderSize + DragHandleOffsets[FCloseButtonWhenDocked, FDragHandleStyle];
        Y := DockedBorderSize;
        //if FDragHandleStyle = dhSingle then
        begin
          inc(Y);
          Dec(Y2);
        end;

        if FCloseButtonWhenDocked then begin
          if DockType <> dtLeftRight then
            Inc (Y, S - 2)
          else
            Dec (Y3, S - 2);
        end;
        Clr := GetSysColor(COLOR_BTNHIGHLIGHT);
        for B := False to (FDragHandleStyle = dhDouble) do begin
          if DockType <> dtLeftRight then
            R := Rect(X, Y, X+3, Y2)
          else
            R := Rect(Y, X, Y3, X+3);
          DrawRaisedEdge (R, True);
          {$IFNDEF FPC}
          if DockType <> dtLeftRight then
            SetPixelV (DC, X, Y2-1, Clr)
          else
            SetPixelV (DC, Y2-1, X, Clr);
          {$ENDIF}
          ExcludeClipRect (DC, R.Left, R.Top, R.Right, R.Bottom);
          Inc (X, 3);
        end;
      end;
      { Close button }
      if FCloseButtonWhenDocked then begin
        R := GetDockedCloseButtonRect(Self, DockType = dtLeftRight);
        DrawFrameControl (DC, R, DFC_CAPTION,
          DFCS_CAPTIONCLOSE or CloseButtonState[FCloseButtonDown]);
        ExcludeClipRect (DC, R.Left, R.Top, R.Right, R.Bottom);
      end;
      if not UsingBackground then begin
        if DockType <> dtLeftRight then
          R := Rect(DockedBorderSize, DockedBorderSize,
            DockedBorderSize+S, Y2)
        else
          R := Rect(DockedBorderSize, DockedBorderSize,
            Y2, DockedBorderSize+S);
        FillRect (DC, R, Brush);
      end;
      RestoreDC (DC, SaveIndex);
    end;

    DeleteObject (Brush);
  finally
    //if not DrawToDC then   ReleaseDC (Handle, DC);
  end;

end;

procedure TCustomToolWindowX2.EndUpdate;
begin
  Dec (FDisableArrangeControls);
  if FArrangeNeeded and (FDisableArrangeControls = 0) then
    ArrangeControls;
end;

procedure TCustomToolWindowX2.GetDockRowSize(var AHeightOrWidth: Integer);
begin
  if Docked then
    with DockedTo do begin
      BuildRowInfo;
      AHeightOrWidth := DockedTo.GetRowSize(FDockRow, Self);
    end
  else
    GetBarSize (AHeightOrWidth, dtNotDocked);
end;



//function GetMDIParent (const Form: TForm): TForm;
function GetMDIParent (const Form: {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm {$ENDIF}):
  {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm $ENDIF};
{ Returns the parent of the specified MDI child form. But, if Form isn't a
  MDI child, it simply returns Form. }
var
  I, J: Integer;
begin
  Result := Form;
  if Form = nil then Exit;
  if {$IFDEF TB97D3} (Form is TForm) and {$ENDIF}
     (TForm(Form).FormStyle = fsMDIChild) then
    for I := 0 to Screen.FormCount-1 do
      with Screen.Forms[I] do begin
        if FormStyle <> fsMDIForm then Continue;
        for J := 0 to MDIChildCount-1 do
          if MDIChildren[J] = Form then begin
            Result := Screen.Forms[I];
            Exit;
          end;
      end;
end;

function TCustomToolWindowX2.GetShowingState: Boolean;
var
  HideFloatingToolbars: Boolean;
  ParentForm, MDIParentForm: {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF};
begin
  Result := Showing and (FHidden = 0);
  if not Docked and not(csDesigning in ComponentState) then begin
    HideFloatingToolbars := FFloatingMode = fmOnTopOfParentForm;
    if HideFloatingToolbars then begin
      ParentForm := GetToolWindowParentForm(Self);
      MDIParentForm := GetMDIParent(ParentForm);
      if Assigned(ParentForm) and Assigned(MDIParentForm) then begin
        HideFloatingToolbars := not ParentForm.HandleAllocated or
          not MDIParentForm.HandleAllocated;
        if not HideFloatingToolbars then begin
          HideFloatingToolbars :=  IsIconic({$IFDEF FPC}HWND(nil) {$ELSE} Application.Handle {$ENDIF}) or
            not IsWindowVisible(ParentForm.Handle) or IsIconic(ParentForm.Handle);
          if MDIParentForm <> ParentForm then
            HideFloatingToolbars := HideFloatingToolbars or
              not IsWindowVisible(MDIParentForm.Handle) or IsIconic(MDIParentForm.Handle);
        end;
      end;
    end;
    Result := Result and not (HideFloatingToolbars or (FHideWhenInactive and not ApplicationIsActive));
  end;

end;

function TCustomToolWindowX2.IsLastDockStored: Boolean;
begin
  Result := FDockedTo = nil;
end;

procedure TCustomToolWindowX2.Moved;
begin
  if not(csLoading in ComponentState) and (FDisableOnMove <= 0) then
    DoMove;
end;

procedure TCustomToolWindowX2.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  if (not AutoSizeDelayed) and ((AWidth <> Width) or (AHeight <> Height)) then
    SizeChanging (AWidth, AHeight);
  { This allows you to drag the toolbar around the dock at design time }
  if (csDesigning in ComponentState) and not(csLoading in ComponentState) and
     Docked and (not AutoSizeDelayed) and ((ALeft <> Left) or (ATop <> Top)) then begin
    if not(DockedTo.Position in PositionLeftOrRight) then begin
      FDockRow := DockedTo.GetDesignModeRowOf(ATop+(Height div 2));
      FDockPos := ALeft;
    end
    else begin
      FDockRow := DockedTo.GetDesignModeRowOf(ALeft+(Width div 2));
      FDockPos := ATop;
    end;
    {$IFDEF FPC} self.BeginUpdateBounds;{$ENDIF}
    inherited SetBounds (Left, Top, AWidth, AHeight);  { only pass any size changes }
    {$IFDEF FPC} self.EndUpdateBounds;{$ENDIF}
    DockedTo.ArrangeToolbars (False);  { let ArrangeToolbars take care of position changes }
  end
  else begin
    inherited;
    if not(csLoading in ComponentState) and not Docked and (not AutoSizeDelayed) then
      FFloatingTopLeft := BoundsRect.TopLeft;
  end;
end;

procedure TCustomToolWindowX2.SetDockedTo(const Value: TDockX2);
begin
  if Assigned(Value) then
    Parent := Value
  else
    Parent := ValidToolWindowParentForm(Self);
end;

procedure TCustomToolWindowX2.SetDockPos(const Value: Integer);
begin
  FDockPos := Value;
  if Docked then
    DockedTo.ArrangeToolbars (False);
end;

procedure TCustomToolWindowX2.SetDockRow(const Value: Integer);
begin
  FDockRow := Value;
  if Docked then
    DockedTo.ArrangeToolbars (False);
end;

procedure TCustomToolWindowX2.SetFullSize(const Value: Boolean);
begin
  if FFullSize <> Value then begin
    FFullSize := Value;
    ArrangeControls;
  end;
end;

procedure TCustomToolWindowX2.SetLastDock(Value: TDockX2);
begin
  if FUseLastDock and Assigned(FDockedTo) then
    { When docked, LastDock must be equal to DockedTo }
    Value := FDockedTo;
  if FLastDock <> Value then begin
    if Assigned(FLastDock) and (FLastDock <> Parent) then
      FLastDock.ChangeDockList (False, Self);
    FLastDock := Value;
    if Assigned(Value) then begin
      FUseLastDock := True;
      Value.FreeNotification (Self);
      Value.ChangeDockList (True, Self);
    end;
  end;
end;

procedure TCustomToolWindowX2.SetParent(AParent: TWinControl);
  procedure UpdateFloatingToolWindows;
  var LT,BR : TPoint;
  Margin : TRect;
  begin
    if Parent is TFloatingWindowParent then begin
      if FloatingToolWindows = nil then
        FloatingToolWindows := TList.Create;
      if FloatingToolWindows.IndexOf(Self) = -1 then
        FloatingToolWindows.Add (Self);
      //SetBounds (FFloatingTopLeft.X, FFloatingTopLeft.Y, Width, Height);
      //x2nie
      SetBounds(0,0,Width,Height);
      LT := Parent.ClientToScreen(Point(0,0));
      BR := Parent.ClientToScreen( Parent.ClientRect.BottomRight);
      Margin.Left := LT.X - Parent.Left;
      Margin.Top  := LT.Y - Parent.Top;
      Margin.Right  := Parent.Left + Parent.Width - BR.X;
      Margin.Bottom := Parent.Top + Parent.Height - BR.Y;
      Parent.SetBounds(
          FFloatingTopLeft.X - Margin.Left,
          FFloatingTopLeft.Y - Margin.Top,
          Width  + Margin.Right,
          Height + Margin.Bottom);
      {with FFloatingRect do
        Parent.SetBounds(
            Left - Margin.Left,
            Top - Margin.Top,
            Right-Left + Margin.Left + Margin.Right,
            Bottom-Top + Margin.Top + Margin.Bottom
            );}
      {with FFloatingRect do
        Parent.SetBounds(
            Left,
            Top,
            Right-Left + Margin.Left + Margin.Right,
            Bottom-Top + Margin.Top + Margin.Bottom
            );}

      //with moveRect do Parent.SetBounds(Left, Top, Right-Left, Bottom-Top);

    end
    else 
      if Assigned(FloatingToolWindows) then begin
        FloatingToolWindows.Remove (Self);
        if FloatingToolWindows.Count = 0 then begin
          FloatingToolWindows.Free;
          FloatingToolWindows := nil;
        end;
      end;
  end;
  function ParentToDockedTo (const Ctl: TWinControl): TDockX2;
  begin
    if Ctl is TDockX2 then
      Result := TDockX2(Ctl)
    else
      Result := nil;
  end;
var
  {$IFDEF TBX2_DRAGDROP}
  NewFloatParent: TFloatingWindowParent;
  {$ENDIF}
  OldDockedTo, NewDockedTo: TDockX2;
  OldParent: TWinControl;
begin
  if (AParent <> nil) and not(AParent is TDockX2) and
     not(AParent is {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF}) then
    raise EInvalidOperation.Create(STBx2ToolwinParentNotAllowed);
  {$IFDEF TBX2_DRAGDROP}
  if not(csDesigning in ComponentState) and
     (AParent is {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF}) then begin
    if (FFloatParent = nil) or (FFloatParent.FParentForm <> AParent) then begin
      NewFloatParent := TFloatingWindowParent.Create(nil);
      try
        with NewFloatParent do begin
          TWinControl(FParentForm) := AParent;
          Name := Format('TB97FloatingWindowParent_%.8x', [Longint(NewFloatParent)]);
          { ^ Must assign a unique name. In previous versions, reading in
            components at run-time that had no name caused them to get assigned
            names like "_1" because a component with no name -- the
            TFloatingWindowParent form -- already existed. }
          //BorderStyle := bsNone;
          SetBounds (0, 0, 0, 0);
          //SetBounds (0, 0, 600, 400);
          ShowHint := True;
          Visible := True;
        end;
      except
        NewFloatParent.Free;
        raise;
      end;
      FFloatParent := NewFloatParent;
    end;
    AParent.FreeNotification (Self);
    AParent := FFloatParent;
  end;
  {$ENDIF}

  OldDockedTo := ParentToDockedTo(Parent);
  NewDockedTo := ParentToDockedTo(AParent);

  if AParent = Parent then begin
    { Even though AParent is the same as the current Parent, this code is
      necessary because when the VCL destroys the parent of the tool window,
      it calls TWinControl.Remove to set FParent instead of using SetParent.
      However TControl.Destroy does call SetParent(nil), so it is
      eventually notified of the change before it is destroyed. }
    FDockedTo := ParentToDockedTo(Parent);
    FDocked := FDockedTo <> nil;
    UpdateFloatingToolWindows;
  end
  else begin
    if not(csDestroying in ComponentState) and Assigned(AParent) then begin
      if Assigned(FOnDockChanging) then
        FOnDockChanging (Self);
      if Assigned(FOnDockChangingEx) then
        FOnDockChangingEx (Self, NewDockedTo);
      if Assigned(FOnRecreating) then
        FOnRecreating (Self);
    end;

    { Before changing between docked and floating state (and vice-versa)
      or between docks, increment FHidden and call UpdateVisibility to hide the
      toolbar. This prevents any flashing while it's being moved }
    Inc (FHidden);
    Inc (FDisableOnMove);
    try
      UpdateVisibility;
      if Assigned(OldDockedTo) then
        OldDockedTo.BeginUpdate;
      if Assigned(NewDockedTo) then
        NewDockedTo.BeginUpdate;
      DisableAutoSizing;
      try
        if Assigned(AParent) then begin
          DoDockChangingHidden (NewDockedTo);
          { Must pre-arrange controls in new dock orientation before changing
            the Parent }
          if FLastDockTypeSet then
            CustomArrangeControls (FLastDockType, NewDockedTo, False);
        end;
        FArrangeNeeded := True;  { force EndUpdate to rearrange }
        BeginUpdate;
        try
          if Parent is TDockX2 then begin
            if not FUseLastDock then
              TDockX2(Parent).ChangeDockList (False, Self);
            TDockX2(Parent).ToolbarVisibilityChanged (Self, True);
          end;

          OldParent := Parent;

          { Ensure that the handle is destroyed now so that any messages in the queue
            get flushed. This is neccessary since existing messages may reference
            FDockedTo or FDocked, which is changed below. }
          inherited SetParent (nil);
          { ^ Note to self: SetParent is used instead of DestroyHandle because it does
            additional processing }
          FDockedTo := NewDockedTo;
          FDocked := FDockedTo <> nil;
          try
            inherited;
          except
            { Failure is rare, but just in case, restore FDockedTo and FDocked back. }
            FDockedTo := ParentToDockedTo(Parent);
            FDocked := FDockedTo <> nil;
            raise;
          end;
          { Force a recalc of NC sizes now so that FNonClientWidth &
            FNonClientHeight are accurate, even if the control didn't receive
            a WM_NCCALCSIZE message because it has no handle. }
          CalculateNonClientSizes (nil);

          if OldParent is TFloatingWindowParent then begin
            if FFloatParent = OldParent then FFloatParent := nil;
            OldParent.Free;
          end;

          if Parent is TDockX2 then begin
            if FUseLastDock then begin
              LastDock := TDockX2(Parent);  { calls ChangeDockList if LastDock changes }
              TDockX2(Parent).ToolbarVisibilityChanged (Self, False);
            end
            else
              TDockX2(Parent).ChangeDockList (True, Self);
          end;

          UpdateFloatingToolWindows;
        finally
          EndUpdate;
        end;
        if Assigned(Parent) then begin
          FLastDockType := GetDockTypeOf(NewDockedTo);
          FLastDockTypeSet := True;
        end;
      finally
        EnableAutoSizing;
        if Assigned(NewDockedTo) then
          NewDockedTo.EndUpdate;
        if Assigned(OldDockedTo) then
          OldDockedTo.EndUpdate;
      end;
    finally
      Dec (FDisableOnMove);
      Dec (FHidden);
      UpdateVisibility;
      { ^ The above UpdateVisibility call not only updates the tool window's
        visibility after decrementing FHidden, it also sets the
        active/inactive state of the caption. }
    end;
    if Assigned(Parent) then
      Moved;

    if not(csDestroying in ComponentState) and Assigned(AParent) then begin
      if Assigned(FOnRecreated) then
        FOnRecreated (Self);
      if Assigned(FOnDockChanged) then
        FOnDockChanged (Self);
    end;
  end;


end;

procedure TCustomToolWindowX2.SizeChanging(const AWidth, AHeight: Integer);
begin
end;

procedure TCustomToolWindowX2.UpdateVisibility;
begin
///  SetInactiveCaption (not Docked and (not FHideWhenInactive and not ApplicationIsActive));
  if HandleAllocated and (IsWindowVisible(Handle) <> GetShowingState) then
    Perform (CM_SHOWINGCHANGED, 0, 0);
end;



procedure TCustomToolWindowX2.SetBorderStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then begin
    FBorderStyle := Value;
    //if Docked then RecalcNCArea (Self);
    Invalidate;
  end;
end;


procedure TCustomToolWindowX2.SetDragHandleStyle(
  const Value: TDragHandleStyle);
begin
  if FDragHandleStyle <> Value then begin
    FDragHandleStyle := Value;
    if Docked then
      //RecalcNCArea (Self);
      ArrangeControls;
    Invalidate;
  end;
end;



procedure TCustomToolWindowX2.SetCloseButtonWhenDocked(
  const Value: Boolean);
begin
  if FCloseButtonWhenDocked <> Value then begin
    FCloseButtonWhenDocked := Value;
    if Docked then
      //RecalcNCArea (Self);
      ArrangeControls;
    Invalidate;
  end;
end;

constructor TCustomToolWindowX2.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle +
    [csAcceptsControls, csClickEvents, csDoubleClicks, csSetCaption] -
    [csCaptureMouse{capturing is done manually}, csOpaque];

  GetParams (FParams);

  {$IFNDEF TBX2_DRAGDROP}
  DragKind := dkDock;
  DragMode := dmAutomatic;
  {$ENDIF}

  FActivateParent := True;
  FBorderStyle := bsSingle;
  FDockableTo := [dpTop, dpBottom, dpLeft, dpRight];
  FCloseButton := True;
  FResizable := True;
  FShowCaption := True;
  FHideWhenInactive := True;
  FUseLastDock := True;
  FDockPos := -1;
  FRowsMin := 1;
  Color := clBtnFace;
end;

procedure TCustomToolWindowX2.SetCloseButton(const Value: Boolean);
begin
  if FCloseButton <> Value then begin
    FCloseButton := Value;

    { Update the close button's visibility }
    //InvalidateFloatingNCArea ([twrdCaption, twrdCloseButton]);
    Invalidate;
  end;
end;

procedure TCustomToolWindowX2.SetFloatingMode(
  const Value: TToolWindowFloatingMode);
begin
  if FFloatingMode <> Value then begin
    FFloatingMode := Value;
    if HandleAllocated then
      Perform (CM_SHOWINGCHANGED, 0, 0);
  end;
end;

procedure TCustomToolWindowX2.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then begin
    FShowCaption := Value;
    if not Docked then
      ///RecalcNCArea (Self);
  end;
end;

procedure TCustomToolWindowX2.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  function ControlExistsAtPos (const P: TPoint): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if PtInRect(ClientRect, P) then
      for I := 0 to ControlCount-1 do
        if not ChildControlTransparent(Controls[I]) and Controls[I].Visible and
           PtInRect(Controls[I].BoundsRect, P) then begin
          Result := True;
          Break;
        end;
  end;
begin
  inherited;
  if (Button <> mbLeft) or
     { Ignore message if user clicked on a child control that was probably
       disabled }
     ControlExistsAtPos(Point(X, Y)) or
     (Docked and not DockedTo.FAllowDrag) then
    Exit;

  { Handle double click }
  if ssDouble in Shift then begin
    if Docked then begin
      if DockMode = dmCanFloat then begin
        Parent := GetToolWindowParentForm(Self);
        MoveOnScreen (True);
      end;
    end
    else
    if Assigned(LastDock) then
      Parent := LastDock
    else
    if Assigned(DefaultDock) then begin
      FDockRow := ForceDockAtTopRow;
      FDockPos := ForceDockAtLeftPos;
      Parent := DefaultDock;
    end;
    Exit;
  end;

  {$IFDEF TBX2_DRAGDROP}
  BeginMoving (X, Y);
  MouseUp (mbLeft, [], -1, -1);
  {$ENDIF}
end;

function TCustomToolWindowX2.ChildControlTransparent(
  Ctl: TControl): Boolean;
begin
  Result := False;
end;

procedure TCustomToolWindowX2.MoveOnScreen(
  const OnlyIfFullyOffscreen: Boolean);
{ Moves the (floating) toolbar so that it is fully (or at least mostly) in
  view on the screen }
var
  R, S, Test: TRect;
begin
  if not Docked then begin
    R := BoundsRect;
    S := GetDesktopAreaOfMonitorContainingRect(R);

    if OnlyIfFullyOffscreen and IntersectRect(Test, R, S) then
      Exit;

    if R.Right > S.Right then
      OffsetRect (R, S.Right - R.Right, 0);
    if R.Bottom > S.Bottom then
      OffsetRect (R, 0, S.Bottom - R.Bottom);
    if R.Left < S.Left then
      OffsetRect (R, S.Left - R.Left, 0);
    if R.Top < S.Top then
      OffsetRect (R, 0, S.Top - R.Top);
    BoundsRect := R;
  end;
end;

procedure TCustomToolWindowX2.SetDefaultDock(const Value: TDockX2);
begin
  if FDefaultDock <> Value then begin
    FDefaultDock := Value;
    if Assigned(Value) then
      Value.FreeNotification (Self);
  end;
end;

{$IFDEF TBX2_DRAGDROP}
procedure TCustomToolWindowX2.BeginMoving(const InitX, InitY: Integer);
type
  PDockedSize = ^TDockedSize;
  TDockedSize = record
    Dock: TDockX2;
    Size: TPoint;
  end;
var
  DockList: TList;
  NewDockedSizes: TList; {items are pointers to TDockedSizes}
  MouseOverDock: TDockX2;
  MoveRect: TRect;
  PreventDocking, PreventFloating: Boolean;
  ScreenDC: HDC;
  OldCursor: HCURSOR;
  NPoint, DPoint: TPoint;

  procedure Dropped;
  var
    NewDockRow: Integer;
    Before: Boolean;
    MoveRectClient: TRect;
    C: Integer;
  begin
    if MouseOverDock <> nil then begin
      MoveRectClient := MoveRect;
      MapWindowPoints (0, MouseOverDock.Handle, MoveRectClient, 2);
      if not(MouseOverDock.Position in PositionLeftOrRight) then
        C := (MoveRectClient.Top+MoveRectClient.Bottom) div 2
      else
        C := (MoveRectClient.Left+MoveRectClient.Right) div 2;
      NewDockRow := MouseOverDock.GetRowOf(C, Before);
      if Before then
        MouseOverDock.InsertRowBefore (NewDockRow)
      else
        if FullSize and
           (MouseOverDock.GetNumberOfToolbarsOnRow(NewDockRow, Self) <> 0) then begin
          Inc (NewDockRow);
          MouseOverDock.InsertRowBefore (NewDockRow);
        end;
      FDockRow := NewDockRow;
      if not(MouseOverDock.Position in PositionLeftOrRight) then
        FDockPos := MoveRectClient.Left
      else
        FDockPos := MoveRectClient.Top;
      Parent := MouseOverDock;
      DockedTo.ArrangeToolbars (True);
    end
    else begin
      FFloatingTopLeft := MoveRect.TopLeft;
      FFloatingRect := MoveRect;//x2nie
      if DockedTo <> nil then
        Parent := ValidToolWindowParentForm(Self)
      else
        //SetBounds (FFloatingTopLeft.X, FFloatingTopLeft.Y, Width, Height);
        Parent.SetBounds(FFloatingTopLeft.X, FFloatingTopLeft.Y, Parent.Width, Parent.Height);
    end;

    { Make sure it doesn't go completely off the screen }
    MoveOnScreen (True);
  end;

  procedure MouseMoved;
  var
    OldMouseOverDock: TDockX2;
    OldMoveRect: TRect;
    Pos: TPoint;

    function CheckIfCanDockTo (Control: TDockX2): Boolean;
    const
      DockSensX = 32;
      DockSensY = 20;
    var
      R, S, Temp: TRect;
      I: Integer;
      Sens: Integer;
    begin
      with Control do begin
        Result := False;

        GetWindowRect (Handle, R);
        for I := 0 to NewDockedSizes.Count-1 do
          with PDockedSize(NewDockedSizes[I])^ do begin
            if Dock <> Control then Continue;
            S := Bounds(Pos.X-MulDiv(Size.X-1, NPoint.X, DPoint.X),
              Pos.Y-MulDiv(Size.Y-1, NPoint.Y, DPoint.Y),
              Size.X, Size.Y);
            Break;
          end;
        if (R.Left = R.Right) or (R.Top = R.Bottom) then begin
          if not(Control.Position in PositionLeftOrRight) then
            InflateRect (R, 0, 1)
          else
            InflateRect (R, 1, 0);
        end;

        { Like Office 97, distribute ~32 pixels of extra dock detection area
          to the left side if the toolbar was grabbed at the left, both sides
          if the toolbar was grabbed at the middle, or the right side if
          toolbar was grabbed at the right. If outside, don't try to dock. }
        Sens := MulDiv(DockSensX, NPoint.X, DPoint.X);
        if (Pos.X < R.Left-(DockSensX-Sens)) or (Pos.X > R.Right-1+Sens) then
          Exit;

        { Don't try to dock to the left or right if pointer is above or below
          the boundaries of the dock }
        if (Control.Position in PositionLeftOrRight) and
           ((Pos.Y < R.Top) or (Pos.Y >= R.Bottom)) then
          Exit;

        { And also distribute ~20 pixels of extra dock detection area to
          the top or bottom side }
        Sens := MulDiv(DockSensY, NPoint.Y, DPoint.Y);
        if (Pos.Y < R.Top-(DockSensY-Sens)) or (Pos.Y > R.Bottom-1+Sens) then
          Exit;

        Result := IntersectRect(Temp, R, S);
      end;
    end;
  var
    R, R2: TRect;
    I: Integer;
    Dock: TDockX2;
    Accept: Boolean;
    TL, BR: TPoint;
  begin
    OldMouseOverDock := MouseOverDock;
    OldMoveRect := MoveRect;

    GetCursorPos (Pos);

    { Check if it can dock }
    MouseOverDock := nil;
    if not PreventDocking then
      for I := 0 to DockList.Count-1 do begin
        Dock := DockList[I];
        if CheckIfCanDockTo(Dock) then begin
          MouseOverDock := Dock;
          Accept := True;
          if Assigned(MouseOverDock.FOnRequestDock) then
            MouseOverDock.FOnRequestDock (MouseOverDock, Self, Accept);
          if Accept then
            Break
          else
            MouseOverDock := nil;
        end;
      end;

    { If not docking, clip the point so it doesn't get dragged under the
      taskbar }
    if MouseOverDock = nil then begin
      R := GetDesktopAreaOfMonitorContainingPoint(Pos);
      if Pos.X < R.Left then Pos.X := R.Left;
      if Pos.X > R.Right then Pos.X := R.Right;
      if Pos.Y < R.Top then Pos.Y := R.Top;
      if Pos.Y > R.Bottom then Pos.Y := R.Bottom;
    end;

    for I := 0 to NewDockedSizes.Count-1 do
      with PDockedSize(NewDockedSizes[I])^ do begin
        if Dock <> MouseOverDock then Continue;
        MoveRect := Bounds(Pos.X-MulDiv(Size.X-1, NPoint.X, DPoint.X),
          Pos.Y-MulDiv(Size.Y-1, NPoint.Y, DPoint.Y),
          Size.X, Size.Y);
        Break;
      end;

    { Make sure title bar (or at least part of the toolbar) is still accessible
      if it's dragged almost completely off the screen. This prevents the
      problem seen in Office 97 where you drag it offscreen so that only the
      border is visible, sometimes leaving you no way to move it back short of
      resetting the toolbar. }
    if MouseOverDock = nil then begin
      R2 := GetDesktopAreaOfMonitorContainingPoint(Pos);
      R := R2;
      with GetFloatingBorderSize do
        InflateRect (R, -(X+4), -(Y+4));
      if MoveRect.Bottom < R.Top then
        OffsetRect (MoveRect, 0, R.Top-MoveRect.Bottom);
      if MoveRect.Top > R.Bottom then
        OffsetRect (MoveRect, 0, R.Bottom-MoveRect.Top);
      if MoveRect.Right < R.Left then
        OffsetRect (MoveRect, R.Left-MoveRect.Right, 0);
      if MoveRect.Left > R.Right then
        OffsetRect (MoveRect, R.Right-MoveRect.Left, 0);

      GetFloatingNCArea (TL, BR);
      I := R2.Top {+ 4} - TL.Y;
      if MoveRect.Top < I then
        OffsetRect (MoveRect, 0, I-MoveRect.Top);
    end;

    { Empty MoveRect if it's wanting to float but it's not allowed to, and
      set the mouse cursor accordingly. }
    if PreventFloating and not Assigned(MouseOverDock) then begin
      SetRectEmpty (MoveRect);
      //SetCursor (LoadCursor(0, IDC_NO));
      SetCursor(screen.Cursors[crNone]);
    end
    else
      SetCursor (OldCursor);

    { Update the dragging outline }
    DrawDraggingOutline (ScreenDC, @MoveRect, @OldMoveRect, MouseOverDock <> nil,
      OldMouseOverDock <> nil);
  end;
  procedure BuildDockList;
    procedure Recurse (const ParentCtl: TWinControl);
    var
      D: TDockPosition;
      I: Integer;
    begin
      if ContainsControl(ParentCtl) or not ParentCtl.Showing then
        Exit;
      with ParentCtl do begin
        for D := Low(D) to High(D) do
          for I := 0 to ParentCtl.ControlCount-1 do
            if (Controls[I] is TDockX2) and (TDockX2(Controls[I]).Position = D) then
              Recurse (TWinControl(Controls[I]));
        for I := 0 to ParentCtl.ControlCount-1 do
          if (Controls[I] is TWinControl) and not(Controls[I] is TDockX2) then
            Recurse (TWinControl(Controls[I]));
      end;
      if (ParentCtl is TDockX2) and TDockX2(ParentCtl).FAllowDrag and
         (TDockX2(ParentCtl).Position in DockableTo) then
        DockList.Add (ParentCtl);
    end;
  var
    ParentForm: {.$IFDEF TB97D3} TCustomForm {.$ELSE TForm $ENDIF};
    DockFormsList: TList;
    I, J: Integer;
  begin
    ParentForm := GetToolWindowParentForm(Self);
    DockFormsList := TList.Create;
    try
      if Assigned(FDockForms) then begin
        for I := 0 to Screen.CustomFormCount-1 do begin
          J := FDockForms.IndexOf(Screen.CustomForms[I]);
          if (J <> -1) and (FDockForms[J] <> ParentForm) then
            DockFormsList.Add (FDockForms[J]);
        end;
      end;
      if Assigned(ParentForm) then
        DockFormsList.Insert (0, ParentForm);
      for I := 0 to DockFormsList.Count-1 do
        Recurse (DockFormsList[I]);
    finally
      DockFormsList.Free;
    end;
  end;
var
  Accept: Boolean;
  R: TRect;
  Msg: TMsg;
  NewDockedSize: PDockedSize;
  I: Integer;
begin
  Accept := False;

  NPoint := Point(InitX, InitY);
  { Adjust for non-client area }
  GetWindowRect (Handle, R);
  R.BottomRight := ClientToScreen(Point(0, 0));
  Dec (NPoint.X, R.Left-R.Right);
  Dec (NPoint.Y, R.Top-R.Bottom);

  DPoint := Point(Width-1, Height-1);

  PreventDocking := GetKeyState(VK_CONTROL) < 0;
  PreventFloating := DockMode <> dmCanFloat;

  { Build list of all TDock97's on the form }
  DockList := TList.Create;
  try
    if DockMode <> dmCannotFloatOrChangeDocks then
      BuildDockList
    else
      if Docked then
        DockList.Add (DockedTo);
    { Set up potential sizes for each dock type }
    NewDockedSizes := TList.Create;
    try
      New (NewDockedSize);
      try
        with NewDockedSize^ do begin
          Dock := nil;
          Size := OrderControls(False, GetDockTypeOf(DockedTo), nil);
          AddFloatingNCAreaToSize (Size);
        end;
        NewDockedSizes.Add (NewDockedSize);
      except
        Dispose (NewDockedSize);
        raise;
      end;
      for I := 0 to DockList.Count-1 do begin
        New (NewDockedSize);
        try
          with NewDockedSize^ do begin
            Dock := TDockX2(DockList[I]);
            if DockList[I] <> DockedTo then
              Size := OrderControls(False, GetDockTypeOf(DockedTo), Dock)
            else
              Size := Self.ClientRect.BottomRight;
            AddDockedNCAreaToSize (Size, Dock.Position in PositionLeftOrRight);
          end;
          NewDockedSizes.Add (NewDockedSize);
        except
          Dispose (NewDockedSize);
          raise;
        end;
      end;

      { Before locking, make sure all pending paint messages are processed }
      ProcessPaintMessages;

      { Save the original mouse cursor }
      OldCursor := GetCursor;

      { This uses LockWindowUpdate to suppress all window updating so the
        dragging outlines doesn't sometimes get garbled. (This is safe, and in
        fact, is the main purpose of the LockWindowUpdate function)
        IMPORTANT! While debugging you might want to enable the 'TB97DisableLock'
        conditional define (see top of the source code). }
      {$IFNDEF TB97DisableLock}
      LockWindowUpdate (GetDesktopWindow);
      {$ENDIF}
      { Get a DC of the entire screen. Works around the window update lock
        by specifying DCX_LOCKWINDOWUPDATE. }
      {ScreenDC := GetDCEx(GetDesktopWindow, 0,
        DCX_LOCKWINDOWUPDATE or DCX_CACHE or DCX_WINDOW);}
      try
        (*
        SetCapture (Handle);

        { Initialize }
        MouseOverDock := nil;
        SetRectEmpty (MoveRect);
        MouseMoved;
        *)

        SetRectEmpty (MoveRect);
        DrawDraggingOutline (ScreenDC, nil, @MoveRect, True, MouseOverDock <> nil);
        SetCapture (Handle);

        { Initialize }
        MouseOverDock := nil;
        MouseMoved;


        { Stay in message loop until capture is lost. Capture is removed either
          by this procedure manually doing it, or by an outside influence (like
          a message box or menu popping up) }
        while GetCapture = Handle do
        begin
          {$IFDEF FPC}
            Application.ProcessMessages;
            if csLButtonDown in FControlState then
            begin
              MouseMoved;
            end
            else
            begin
              Accept := True;
              Break;
            end;
          {$ELSE}
          case Integer(GetMessage(Msg, 0, 0, 0)) of
            -1: Break; { if GetMessage failed }
            0: begin
                 { Repost WM_QUIT messages }
                 PostQuitMessage (Msg.WParam);
                 Break;
               end;
          end;

          case Msg.Message of
            WM_KEYDOWN, WM_KEYUP:
              { Ignore all keystrokes while dragging. But process Ctrl and Escape }
              case Msg.WParam of
                VK_CONTROL:
                  if PreventDocking <> (Msg.Message = WM_KEYDOWN) then begin
                    PreventDocking := Msg.Message = WM_KEYDOWN;
                    MouseMoved;
                  end;
                VK_ESCAPE:
                  Break;
              end;
            WM_MOUSEMOVE:
              { Note to self: WM_MOUSEMOVE messages should never be dispatched
                here to ensure no hints get shown during the drag process }
              MouseMoved;
            WM_LBUTTONDOWN, WM_LBUTTONDBLCLK:
              { Make sure it doesn't begin another loop }
              Break;
            WM_LBUTTONUP: begin
                Accept := True;
                Break;
              end;
            WM_RBUTTONDOWN..WM_MBUTTONDBLCLK:
              { Ignore all other mouse up/down messages }
              ;
          else
            TranslateMessage (Msg);
            DispatchMessage (Msg);
          end;
          {$ENDIF}
        end;
      finally
        { Since it sometimes breaks out of the loop without capture being
          released }
        if GetCapture = Handle then
          ReleaseCapture;

      { Hide dragging outline. Since NT will release a window update lock if
        another thread comes to the foreground, it has to release the DC
        and get a new one for erasing the dragging outline. Otherwise,
        the DrawDraggingOutline appears to have no effect when this happens. }
        {ReleaseDC (GetDesktopWindow, ScreenDC);
        ScreenDC := GetDCEx(GetDesktopWindow, 0,
          DCX_LOCKWINDOWUPDATE or DCX_CACHE or DCX_WINDOW);}
        DrawDraggingOutline (ScreenDC, nil, @MoveRect, True, MouseOverDock <> nil);
        //ReleaseDC (GetDesktopWindow, ScreenDC);

        { Release window update lock }
        {$IFNDEF TB97DisableLock}
        LockWindowUpdate (0);
        {$ENDIF}
      end;
    finally
      for I := NewDockedSizes.Count-1 downto 0 do
        Dispose (PDockedSize(NewDockedSizes[I]));
      NewDockedSizes.Free;
    end;
  finally
    DockList.Free;
  end;

  { Move to new position only if MoveRect isn't empty }
  if Accept and not IsRectEmpty(MoveRect) then
    Dropped;

end;
{$ENDIF}

procedure TCustomToolWindowX2.AddDockedNCAreaToSize(var S: TPoint;
  const LeftRight: Boolean);
var
  TopLeft, BottomRight: TPoint;
begin
  GetDockedNCArea (TopLeft, BottomRight, LeftRight);
  Inc (S.X, TopLeft.X + BottomRight.X);
  Inc (S.Y, TopLeft.Y + BottomRight.Y);
end;


procedure TCustomToolWindowX2.AddFloatingNCAreaToSize(var S: TPoint);
var
  TopLeft, BottomRight: TPoint;
begin
  GetFloatingNCArea (TopLeft, BottomRight);
  Inc (S.X, TopLeft.X + BottomRight.X);
  Inc (S.Y, TopLeft.Y + BottomRight.Y);
end;

procedure TCustomToolWindowX2.DrawDraggingOutline(const DC: HDC;
  const NewRect, OldRect: PRect; const NewDocking, OldDocking: Boolean);

  (*usage:
    { Update the dragging outline }
    DrawDraggingOutline (ScreenDC, @MoveRect, @OldMoveRect, MouseOverDock <> nil,
      OldMouseOverDock <> nil);

    { Hide dragging outline. Since NT will release a window update lock if
        another thread comes to the foreground, it has to release the DC
        and get a new one for erasing the dragging outline. Otherwise,
        the DrawDraggingOutline appears to have no effect when this happens. }

        ReleaseDC (GetDesktopWindow, ScreenDC);
        ScreenDC := GetDCEx(GetDesktopWindow, 0,
          DCX_LOCKWINDOWUPDATE or DCX_CACHE or DCX_WINDOW);

        DrawDraggingOutline (ScreenDC, nil, @MoveRect, True, MouseOverDock <> nil);
        ReleaseDC (GetDesktopWindow, ScreenDC);
  *)       

  {function CreateHalftoneBrush: HBRUSH;
  const
    GrayPattern: array[0..7] of Word =
      ($5555, $AAAA, $5555, $AAAA, $5555, $AAAA, $5555, $AAAA);
  var
    GrayBitmap: HBITMAP;
  begin
    GrayBitmap := CreateBitmap(8, 8, 1, 1, @GrayPattern);
    Result := CreatePatternBrush(GrayBitmap);
    DeleteObject (GrayBitmap);
  end;}

var
  NewSize, OldSize: TSize;
  //Brush: HBRUSH;
  //UFloatingDragWindow : TFloatingDragWindow = nil;
begin
  {Brush := CreateHalftoneBrush;
  try
    with GetFloatingBorderSize do begin
      if NewDocking then NewSize.cx := 1 else NewSize.cx := X;
      NewSize.cy := NewSize.cx;
      if OldDocking then OldSize.cx := 1 else OldSize.cx := X;
      OldSize.cy := OldSize.cx;
    end;
    DrawDragRect (DC, NewRect, OldRect, NewSize, OldSize, Brush, Brush);
  finally
    DeleteObject (Brush);
  end;}

  if NewRect = nil then
  begin
    if Assigned(UFloatingDragWindow) then
    begin
      UFloatingDragWindow.Hide;
      UFloatingDragWindow.Free;
      UFloatingDragWindow := nil;
    end;
  end
  else
  begin
    if not Assigned(UFloatingDragWindow) then
      UFloatingDragWindow := TFloatingDragWindow.Create(nil);
    with GetFloatingBorderSize do begin
      if NewDocking then
        //NewSize.cx := 2
        UFloatingDragWindow.BorderLen := 2
      else
        //NewSize.cx := X;
        UFloatingDragWindow.BorderLen := X;
      //UFloatingDragWindow.BorderLen := NewSize.cx;
      {NewSize.cy := NewSize.cx;
      if OldDocking then OldSize.cx := 1 else OldSize.cx := X;
      OldSize.cy := OldSize.cx;}
    end;      
    with NewRect^ do
    begin
      UFloatingDragWindow.SetBounds(Left, Top, Right - Left, Bottom - Top);
      //UFloatingDragWindow.SetBounds(Left, Top, 200, 200);
    end;
    UFloatingDragWindow.Show;
    UFloatingDragWindow.Update;


  end;    

end;

function TCustomToolWindowX2.GetFloatingBorderSize: TPoint;
{ Returns size of a thick border. Note that, depending on the Windows version,
  this may not be the same as the actual window metrics since it draws its
  own border }
const
  XMetrics: array[Boolean] of Integer = (SM_CXDLGFRAME, SM_CXFRAME);
  YMetrics: array[Boolean] of Integer = (SM_CYDLGFRAME, SM_CYFRAME);
begin
  Result.X := GetSystemMetrics(XMetrics[Resizable]);
  Result.Y := GetSystemMetrics(YMetrics[Resizable]);
end;

procedure TCustomToolWindowX2.GetFloatingNCArea(var TopLeft,
  BottomRight: TPoint);
begin
  with GetFloatingBorderSize do begin
    TopLeft.X := X;
    TopLeft.Y := Y;
    ///if ShowCaption then      Inc (TopLeft.Y, GetSmallCaptionHeight);
    BottomRight.X := X;
    BottomRight.Y := Y;
  end;
end;

procedure TCustomToolWindowX2.GetDockedNCArea(var TopLeft,
  BottomRight: TPoint; const LeftRight: Boolean);
var
  Z: Integer;
begin
  Z := DockedBorderSize;  { code optimization... }
  TopLeft.X := Z;
  TopLeft.Y := Z;
  BottomRight.X := Z;
  BottomRight.Y := Z;
  if not LeftRight then
    Inc (TopLeft.X, DragHandleSizes[CloseButtonWhenDocked, DragHandleStyle])
  else
    Inc (TopLeft.Y, DragHandleSizes[CloseButtonWhenDocked, DragHandleStyle]);
end;

procedure TCustomToolWindowX2.SetResizable(const Value: Boolean);
begin
  if FResizable <> Value then begin
    FResizable := Value;
    if not Docked then
      { Recreate the window handle because Resizable affects whether the
        tool window is created with a WS_THICKFRAME style }
      {$IFNDEF FPC}
      RecreateWnd;
    {$ENDIF}
  end;
end;

procedure TCustomToolWindowX2.AddDockForm(const Form: TCustomForm);
begin
  if Form = nil then Exit;
  if FDockForms = nil then FDockForms := TList.Create;
  if FDockForms.IndexOf(Form) = -1 then begin
    FDockForms.Add (Form);
    Form.FreeNotification (Self);
  end;
end;

procedure TCustomToolWindowX2.RemoveDockForm(const Form: TCustomForm);
begin
  if Assigned(FDockForms) then begin
    FDockForms.Remove (Form);
    if FDockForms.Count = 0 then begin
      FDockForms.Free;
      FDockForms := nil;
    end;
  end;
end;

procedure TCustomToolWindowX2.GetParams(var Params: TToolWindowParams);
begin
  with Params do begin
    CallAlignControls := True;
    ResizeEightCorner := True;
    ResizeClipCursor := True;
  end;
end;

procedure TCustomToolWindowX2.AlignControls(AControl: TControl;
  var Rect: TRect);
{ VCL calls this whenever any child controls in the toolbar are moved, sized,
  inserted, etc. It doesn't need to make use of the AControl and Rect
  parameters. }
begin
  if Params.CallAlignControls then
    inherited;
  ArrangeControls;
end;

procedure TCustomToolWindowX2.CalculateNonClientSizes(R: PRect);
{ Recalculates FNonClientWidth and FNonClientHeight.
  If R isn't nil, it deflates the rectangle to exclude the non-client area. }
var
  Temp: TRect;
  TL, BR: TPoint;
  Z: Integer;
begin
  Temp := Rect(0,0,0,0);
  if R = nil then
    R := @Temp;
  if not Docked then begin
    {GetFloatingNCArea (TL, BR);
    FNonClientWidth := TL.X + BR.X;
    FNonClientHeight := TL.Y + BR.Y;
    with R^ do begin
      Inc (Left, TL.X);
      Inc (Top, TL.Y);
      Dec (Right, BR.X);
      Dec (Bottom, BR.Y);
    end;}
  end
  else begin
    InflateRect (R^, -DockedBorderSize, -DockedBorderSize);
    FNonClientWidth := DockedBorderSize2;
    FNonClientHeight := DockedBorderSize2;
    if DockedTo.FAllowDrag then begin
      Z := DragHandleSizes[FCloseButtonWhenDocked, FDragHandleStyle];
      if not(DockedTo.Position in PositionLeftOrRight) then begin
        Inc (R.Left, Z);
        Inc (FNonClientWidth, Z);
      end
      else begin
        Inc (R.Top, Z);
        Inc (FNonClientHeight, Z);
      end;
    end;
  end;
end;


{procedure TCustomToolWindowX2.WMNCPaint(var Message: TMessage);
begin
  // Don't call inherited because it overrides the default NC painting
  if Docked then
    //DrawDockedNCArea (False, 0, HRGN(Message.WParam))
    Invalidate
  else
    //DrawFloatingNCArea (False, 0, HRGN(Message.WParam), twrdAll);
end;}

function TCustomToolWindowX2.GetClientRect: TRect;
begin
  Result := inherited GetClientRect;
  CalculateNonClientSizes (@Result);
end;

procedure TCustomToolWindowX2.Loaded;
var
  R: TRect;
begin
  //inherited;
  // Adjust coordinates if it was initially floating
  if not FSavedAtRunTime and not(csDesigning in ComponentState) and
     (Parent is TFloatingWindowParent) then begin
    R := BoundsRect;
    MapWindowPoints (ValidToolWindowParentForm(Self).Handle, 0, R, 2);
    BoundsRect := R;
    MoveOnScreen (False);
  end;
  InitializeOrdering;
  // Arranging of controls is disabled while component was loading, so rearrange
    //it now
  ArrangeControls;
  inherited;
end;

procedure TCustomToolWindowX2.InitializeOrdering;
begin

end;

procedure TCustomToolWindowX2.SetRowsMin(const Value: Integer);
begin
  if FRowsMin <> Value then
  begin
    if Value <= 0 then
      Abort;
    FRowsMin := Value;
    Parent.Realign;
  end;
end;

procedure TCustomToolWindowX2.SetImagesList(const Value: TCustomImageList);
begin
  if FImageList <> Value then begin
    if FImageList <> nil then
      FImageList.UnRegisterChanges (FImageChangeLink);
    FImageList := Value;
    if FImageList <> nil then begin
      if FImageChangeLink = nil then begin
        FImageChangeLink := TChangeLink.Create;
        FImageChangeLink.OnChange := ImageListChanged;
      end;
      FImageList.RegisterChanges (FImageChangeLink);
      FImageList.FreeNotification (Self);
    end
    else begin
      FImageChangeLink.Free;
      FImageChangeLink := nil;
    end;
    //UpdateNumGlyphs;
    Repaint;
  end;
end;

procedure TCustomToolWindowX2.ImageListChanged(Sender: TObject);
begin
  Invalidate;
end;

function TCustomToolWindowX2.GetWeight: Integer;
begin
  {LeftRight := Position in PositionLeftOrRight;
  if not LeftRight then
    Inc (CurDockPos, Width)
  else
    Inc (CurDockPos, Height);}

  if Assigned(DockedTo) and (DockedTo.Position in PositionLeftOrRight) then
    Result := Height
  else
    Result := Width;

end;

{ TFloatingWindowParent }

procedure TFloatingWindowParent.CMShowingChanged(var Message: TMessage);
const
  ShowFlags: array[Boolean] of UINT = (
    SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_HIDEWINDOW,
    SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_SHOWWINDOW);
begin
  { Must override TCustomForm/TForm's CM_SHOWINGCHANGED handler so that the
    form doesn't get activated when Visible is set to True. }
  //SetWindowPos (WindowHandle, 0, 0, 0, 0, 0, ShowFlags[Showing and FShouldShow]);

  //x2nie:
  inherited;

end;

constructor TFloatingWindowParent.Create(AOwner: TComponent);
begin
  { Don't use TForm's Create since it attempts to load a form resource, which
    TFloatingWindowParent doesn't have. }
  //inherited;
  CreateNew (AOwner {$IFDEF VER93} , 0 {$ENDIF});
  //Visible := True;
  BorderStyle := bsToolWindow;
  DragKind := dkDock;
  DragMode := dmAutomatic;
end;

procedure TFloatingWindowParent.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  { The WS_EX_TOOLWINDOW style is needed to prevent the form from having
    a taskbar button when Toolbar97 is used in a DLL or OCX. }
  Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW;
end;

{ TFloatingDragWindow }

constructor TFloatingDragWindow.Create(AOwner: TComponent);
begin
  { Don't use TForm's Create since it attempts to load a form resource, which
    TFloatingWindowParent doesn't have. }
  //inherited;
  CreateNew (AOwner {$IFDEF VER93} , 0 {$ENDIF});
  //Visible := True;
  BorderStyle := bsNone;
  Color := clBlue;
  AlphaBlendValue := 100;
  AlphaBlend := True;
  FShape := TShape.Create(self);
  FShape.Align := alClient;
  FShape.Pen.Color := clBlack;
  FShape.Brush.Style := bsClear;
  FShape.Parent := Self;
end;

function TFloatingDragWindow.GetBorderLen: Integer;
begin
  Result := FShape.Pen.Width;
end;

procedure TFloatingDragWindow.SetBorderLen(const Value: Integer);
begin
  FShape.Pen.Width := Value;
end;

end.
