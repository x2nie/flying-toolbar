unit TBx2_Toolbar;


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

{$I TBx2_Ver.inc}

uses
{$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Types, messages,
{$ELSE}
  Windows, Messages,
{$ENDIF}
  Classes, Controls, SysUtils, Graphics,
{$IFDEF TBX2_GR32}
  GR32, GR32_Image,
{$ENDIF}
  TBx2, TBx2_Common, TBx2_Const
  ;


type
  TToolbarParams = record
    InitializeOrderByPosition, DesignOrderByPosition: Boolean;
  end;

  TCustomToolbarX2 = class(TCustomToolWindowX2)
  private
    FFloatingRightX: Integer;
    FOrderListDirty: Boolean;
    
    { Lists }
    SlaveInfo,         { List of slave controls. Items are pointers to TSlaveInfo's }
    GroupInfo,         { List of the control "groups". List items are pointers to TGroupInfo's }
    LineSeps,          { List of the Y locations of line separators. Items are casted in TLineSep's }
    OrderList: TList;
    FToolbarParams: TToolbarParams;  { List of the child controls, arranged using the current "OrderIndex" values }
  
    function ShouldControlBeVisible (const Control: TControl;
      const LeftOrRight: Boolean): Boolean;

      { Internal }
    procedure CleanOrderList;

    procedure SetControlVisible (const Control: TControl;
      const LeftOrRight: Boolean);
    procedure FreeGroupInfo (const List: TList);
    procedure BuildGroupInfo (const List: TList; const TranslateSlave: Boolean;
      const OldDockType, NewDockType: TDockType);

  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    {$IFDEF TBX2_GR32}
    procedure DoPaintBuffer; override;
    {$ELSE}
    procedure Paint;override;
    {$ENDIF}
    //function AdjustedClientArea: TRect; virtual; //client area
    procedure GetBarSize (var ASize: Integer; const DockType: TDockType); override;
    function OrderControls (CanMoveControls: Boolean; PreviousDockType: TDockType;
      DockingTo: TDockX2): TPoint; override;
    procedure GetToolbarParams (var Params: TToolbarParams); dynamic;
    function ChildControlTransparent (Ctl: TControl): Boolean; override;
    procedure GetParams (var Params: TToolWindowParams); override;
    procedure InitializeOrdering; override;

    property ToolbarParams: TToolbarParams read FToolbarParams;
    
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetSlaveControl (const ATopBottom, ALeftRight: TControl);

  published
  end;

  TToolbarX2 = class(TCustomToolbarX2)
  published
    //property ActivateParent;
    property BorderStyle;
    property Caption;
    property Color;
    property CloseButton;
    property CloseButtonWhenDocked;
    //property DefaultDock;
    property DockableTo;
    property DockedTo;
    property DockMode;
    property DockPos;
    property DockRow;
    property DragHandleStyle;
    property FloatingMode;
    property Font;
    property FullSize;
    property HideWhenInactive;
    property Images;
    property LastDock;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Resizable;
    property RowsMin;
    property ShowCaption;
    property ShowHint;
    property TabOrder;
    //property UseLastDock;
    //property Version;
    property Visible;

    {property OnClose;
    property OnCloseQuery;
    property OnDragDrop;
    property OnDragOver;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMove;
    property OnRecreated;
    property OnRecreating;
    property OnDockChanged;
    property OnDockChanging;
    property OnDockChangingEx;
    property OnDockChangingHidden;
    property OnResize;
    property OnVisibleChanged;}

  end;  

  
  { TToolbarSep97 }

  TToolbarSepSize = 1..MaxInt;

  TToolbarSepX2 = class(TGraphicControl)
  private
    FBlank: Boolean;
    FSizeHorz, FSizeVert: TToolbarSepSize;
    procedure SetBlank (Value: Boolean);
    procedure SetSizeHorz (Value: TToolbarSepSize);
    procedure SetSizeVert (Value: TToolbarSepSize);
  protected
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure SetParent (AParent: TWinControl); override;
  public
    constructor Create (AOwner: TComponent); override;
  published
    { These two properties don't need to be stored since it automatically gets
      resized based on the setting of SizeHorz and SizeVert }
    property Width stored False;
    property Height stored False;
    property Blank: Boolean read FBlank write SetBlank default False;
    property SizeHorz: TToolbarSepSize read FSizeHorz write SetSizeHorz default 6;
    property SizeVert: TToolbarSepSize read FSizeVert write SetSizeVert default 6;
    property Visible;
  end;


{$IFOPT J+}
  {$DEFINE _TB97_OPT_J}
  {$J-}  { don't let the following typed constants be modified }
{$ENDIF}
const
  tbx2DefaultBarWidthHeight = 8;

  tbx2TopMarginFloating = 2;
  tbx2TopMarginDocked = 0;
  tbx2TopMargin: array[Boolean] of Integer = (tbx2TopMarginFloating, tbx2TopMarginDocked);
  tbx2BottomMarginFloating = 1;
  tbx2BottomMarginDocked = 0;
  tbx2BottomMargin: array[Boolean] of Integer = (tbx2BottomMarginFloating, tbx2BottomMarginDocked);
  tbx2LeftMarginFloating = 4;
  tbx2LeftMarginDocked = 0;
  tbx2LeftMargin: array[Boolean] of Integer = (tbx2LeftMarginFloating, tbx2LeftMarginDocked);
  tbx2RightMarginFloating = 4;
  tbx2RightMarginDocked = 0;
  tbx2RightMargin: array[Boolean] of Integer = (tbx2RightMarginFloating, tbx2RightMarginDocked);
  tbx2LineSpacing = 6;
{$IFDEF _TB97_OPT_J}
  {$J+}
  {$UNDEF _TB97_OPT_J}
{$ENDIF}
  
implementation

const
  { Constants for registry values. Do not localize! }
  { TCustomToolbar97 specific }
  rvFloatRightX = 'FloatRightX';

type
  { Used internally by the TCustomToolbar97.Resize* procedures }
  PToolbar97SizeData = ^TToolbar97SizeData;
  TToolbar97SizeData = record
    SizeHandle: TToolWindowSizeHandle;
    //NewSizes: TList;  { List of valid new sizes. Items are casted into TSmallPoints }
    NewSizes : TArrayOfTSmallPoint;
    CurRightX: Integer;
    DisableSensCheck, OpSide: Boolean;
    SizeSens: Integer;
  end;

  { Used in TCustomToolbar97.GroupInfo lists }
  PGroupInfo = ^TGroupInfo;
  TGroupInfo = record
    GroupWidth,           { Width in pixels of the group, if all controls were
                            lined up left-to-right }
    GroupHeight: Integer; { Heights in pixels of the group, if all controls were
                            lined up top-to-bottom }
    Members: TList;
  end;

  { Used in TCustomToolbar97.SlaveInfo lists }
  PSlaveInfo = ^TSlaveInfo;
  TSlaveInfo = record
    LeftRight,
    TopBottom: TControl;
  end;

  { Used in TCustomToolbar97.LineSeps lists }
  TLineSep = packed record
    Y: SmallInt;
    Blank: Boolean;
    Unused: Boolean;
  end;

  { Use by CompareControls }
  PCompareExtra = ^TCompareExtra;
  TCompareExtra = record
    Toolbar: TCustomToolbarX2;
    ComparePositions: Boolean;
    CurDockType: TDockType;
  end;

function ControlVisibleOrDesigning (AControl: TControl): Boolean;
begin
  Result := AControl.Visible or (csDesigning in AControl.ComponentState);
end;

function CompareControls (const Item1, Item2, ExtraData: Pointer): Integer; far;
begin
  with PCompareExtra(ExtraData)^ do
    if ComparePositions then begin
      if CurDockType <> dtLeftRight then
        Result := TControl(Item1).Left - TControl(Item2).Left
      else
        Result := TControl(Item1).Top - TControl(Item2).Top;
    end
    else
      with Toolbar.OrderList do
        Result := IndexOf(Item1) - IndexOf(Item2);
end;
  

{ TCustomToolbarX2 }

procedure TCustomToolbarX2.AdjustClientRect(var Rect: TRect);
var LSize : Integer;
begin
  inherited;
{  InflateRect(Rect, -DockedBorderSize, -DockedBorderSize);
  if Docked then
  begin
    LSize := DragHandleSizes[CloseButtonWhenDocked, DragHandleStyle];
    if DockedTo.Position in PositionLeftOrRight then
      Inc(Rect.Top, LSize) //toolbar = vertical
    else
      Inc(Rect.Left, LSize); //toolbar = Horizontal

  end;}

end;

procedure TCustomToolbarX2.BuildGroupInfo(const List: TList;
  const TranslateSlave: Boolean; const OldDockType,
  NewDockType: TDockType);
var
  I: Integer;
  GI: PGroupInfo;
  Children: TList; {items casted into TControls}
  C: TControl;
  NewGroup: Boolean;
  Extra: TCompareExtra;
begin
  FreeGroupInfo (List);
  if ControlCount = 0 then Exit;

  Children := TList.Create;
  try
    for I := 0 to ControlCount-1 do 
      if (not TranslateSlave and ControlVisibleOrDesigning(Controls[I])) or
         (TranslateSlave and ShouldControlBeVisible(Controls[I], NewDockType = dtLeftRight)) then
        Children.Add (Controls[I]);

    with Extra do begin
      Toolbar := Self;
      CurDockType := OldDockType;
      ComparePositions := //(csDesigning in ComponentState) and
        ToolbarParams.DesignOrderByPosition;
    end;
    if Extra.ComparePositions then begin
      CleanOrderList;
      ListSortEx (OrderList, CompareControls, @Extra);
    end;
    ListSortEx (Children, CompareControls, @Extra);

    GI := nil;
    NewGroup := True;
    for I := 0 to Children.Count-1 do begin
      if NewGroup then begin
        NewGroup := False;
        GI := AllocMem(SizeOf(TGroupInfo));
        { Note: AllocMem initializes the newly allocated data to zero }
        GI^.Members := TList.Create;
        List.Add (GI);
      end;
      C := Children[I];
      GI^.Members.Add (C);
      if C is TToolbarSepX2 then
        NewGroup := True
      else begin
        with C do begin
          Inc (GI^.GroupWidth, Width);
          Inc (GI^.GroupHeight, Height);
        end;
      end;
    end;
  finally
    Children.Free;
  end;
end;

function TCustomToolbarX2.ChildControlTransparent(Ctl: TControl): Boolean;
begin
  Result := Ctl is TToolbarSepX2;
end;

procedure TCustomToolbarX2.CleanOrderList;
{ TCustomToolbar97 uses a CM_CONTROLLISTCHANGE handler to detect when new
  controls are added to the toolbar. The handler adds the new controls to
  OrderList, which can be manipulated by the application using the OrderIndex
  property.
  The only problem is, the VCL relays CM_CONTROLLISTCHANGE messages
  to all parents of a control, not just the immediate parent. In pre-1.76
  versions of Toolbar97, OrderList contained not only the immediate children
  of the toolbar, but their children too. So this caused the OrderIndex
  property to return unexpected results.
  What this method does is clear out all controls in OrderList that aren't
  immediate children of the toolbar. (A check of Parent can't be put into the
  CM_CONTROLLISTCHANGE handler because that message is sent before a new
  Parent is assigned.) }
var
  I: Integer;
begin
  if not FOrderListDirty then
    Exit;
  I := 0;
  while I < OrderList.Count do begin
    if TControl(OrderList.List[I]).Parent <> Self then
      OrderList.Delete (I)
    else
      Inc (I);
  end;
  FOrderListDirty := False;
end;

constructor TCustomToolbarX2.Create(AOwner: TComponent);
begin
  inherited;
  GetToolbarParams (FToolbarParams);
  GroupInfo := TList.Create;
  SlaveInfo := TList.Create;
  LineSeps := TList.Create;
  OrderList := TList.Create;
  {$IFDEF TBX2_GR32}
  Options := [pboAutoFocus, pboWantArrowKeys];
  {$ENDIF}
  Cursor := crSize;
end;

{$IFDEF TBX2_GR32}
procedure TCustomToolbarX2.DoPaintBuffer;
var r : TRect;
begin
  inherited;
  R := BoundsRect;
  Buffer.FrameRectS(R, clTrGreen32);

  //Buffer.FrameRectS(AdjustedClientArea, clRed32);
  R := ClientRect;
  //AdjustClientRect(R);
  Buffer.FrameRectS(R, clTrRed32);
end;
{$ELSE}
procedure TCustomToolbarX2.Paint;
var r : TRect;
begin
  inherited;
  R := BoundsRect;
  Canvas.Pen.Color:= clGreen;
  Canvas.FrameRect(R);

  //Buffer.FrameRectS(AdjustedClientArea, clRed32);
  R := ClientRect;
  //AdjustClientRect(R);
  Canvas.Pen.Color:=clRed;
  Canvas.FrameRect(R);
end;
{$ENDIF}

procedure TCustomToolbarX2.FreeGroupInfo(const List: TList);
var
  I: Integer;
  L: PGroupInfo;
begin
  if List = nil then Exit;
  for I := List.Count-1 downto 0 do begin
    L := List.Items[I];
    if Assigned(L) then begin
      L^.Members.Free;
      FreeMem (L);
    end;
    List.Delete (I);
  end;
end;

procedure TCustomToolbarX2.GetBarSize(var ASize: Integer;
  const DockType: TDockType);
var
  I: Integer;
begin
  ASize := tbx2DefaultBarWidthHeight {* FRowsMin};
  for I := 0 to ControlCount-1 do
    ///if not(Controls[I] is TToolbarSep97) then
      with Controls[I] do begin
        if ShouldControlBeVisible(Controls[I], DockType = dtLeftRight) then begin
          if DockType = dtLeftRight then begin
            if Width > ASize then ASize := Width;
          end
          else begin
            if Height > ASize then ASize := Height;
          end;
        end;
      end;


end;

procedure TCustomToolbarX2.GetParams(var Params: TToolWindowParams);
begin
  inherited;
  with Params do begin
    CallAlignControls := False;
    ResizeEightCorner := False;
    ResizeClipCursor := False;
  end;
end;

procedure TCustomToolbarX2.GetToolbarParams(var Params: TToolbarParams);
begin
  with Params do begin
    InitializeOrderByPosition := True;
    DesignOrderByPosition := True;
  end;
end;

procedure TCustomToolbarX2.InitializeOrdering;
var
  Extra: TCompareExtra;
begin
  inherited;
  { Initialize order of items in OrderList }
  if ToolbarParams.InitializeOrderByPosition then begin
    with Extra do begin
      Toolbar := Self;
      ComparePositions := True;
      CurDockType := GetDockTypeOf(DockedTo);
    end;
    CleanOrderList;
    ListSortEx (OrderList, CompareControls, @Extra);
  end;
end;

function TCustomToolbarX2.OrderControls(CanMoveControls: Boolean;
  PreviousDockType: TDockType; DockingTo: TDockX2): TPoint;
{ This arranges the controls on the toolbar }
var
  NewDockType: TDockType;
  NewDocked: Boolean;
  RightX, I: Integer;
  CurBarSize, DockRowSize: Integer;
  GInfo: TList;
  AllowWrap: Boolean;
  MinPosPixels, MinRowPixels, CurPosPixel, CurLinePixel, G: Integer;
  GoToNewLine: Boolean;
  GI: PGroupInfo;
  Member: TControl;
  MemberIsSep: Boolean;
  GroupPosSize, MemberPosSize: Integer;
  PreviousSep: TToolbarSepX2;  PrevMinPosPixels: Integer;
  NewLineSep: TLineSep;
  CR : TRect;
label 1;
begin

  Result := Point(32,8);//x2nie
  if (csLoading in ComponentState) then
    Exit;
  NewDockType := GetDockTypeOf(DockingTo);
  NewDocked := Assigned(DockingTo);

  RightX := FFloatingRightX;
  if (NewDockType <> dtNotDocked) or (RightX = 0) then
    RightX := High(RightX)
  else begin
    { Make sure RightX isn't less than the smallest sized control + margins,
      in case one of the *LoadToolbarPositions functions happened to read
      a value too small. }
    for I := 0 to ControlCount-1 do
      if not(Controls[I] is TToolbarSepX2) then
        with Controls[I] do
          if Width + (tbX2LeftMarginFloating+tbX2RightMarginFloating) > RightX then
            RightX := Width + (tbX2LeftMarginFloating+tbX2RightMarginFloating);
  end;

  if CanMoveControls and (SlaveInfo.Count <> 0) then
    for I := 0 to ControlCount-1 do
      if not(Controls[I] is TToolbarSepX2) then
        SetControlVisible (Controls[I], NewDockType = dtLeftRight);

  GetBarSize (CurBarSize, NewDockType);
  if (DockingTo <> nil) and (DockingTo = DockedTo) then
    GetDockRowSize (DockRowSize)
  else
    DockRowSize := CurBarSize;

  if CanMoveControls then
    GInfo := GroupInfo
  else
    GInfo := TList.Create;
  try
    BuildGroupInfo (GInfo, not CanMoveControls, PreviousDockType, NewDockType);

    if CanMoveControls then
      LineSeps.Clear;


    CurLinePixel := tbX2TopMargin[NewDocked];
    MinPosPixels := tbX2LeftMargin[NewDocked];
    //x2nie:
    CR := Self.ClientRect;
    if NewDockType <> dtLeftRight then
    begin
      Inc(CurLinePixel, CR.Top);
      Inc(MinPosPixels, CR.Left);
    end
    else
    begin
      Inc(CurLinePixel, CR.Left);
      Inc(MinPosPixels, CR.Top);
    end;



    //Inc(MinPosPixels, CR.Left);

    if GInfo.Count <> 0 then begin
      AllowWrap := not NewDocked;
      CurPosPixel := MinPosPixels;
      GoToNewLine := False;
      PreviousSep := nil;
      PrevMinPosPixels := 0;
      for G := 0 to GInfo.Count-1 do begin
        GI := PGroupInfo(GInfo[G]);

        if NewDockType <> dtLeftRight then
          GroupPosSize := GI^.GroupWidth
        else
          GroupPosSize := GI^.GroupHeight;
        if AllowWrap and
           (GoToNewLine or (CurPosPixel+GroupPosSize+tbX2RightMargin[NewDocked] > RightX)) then begin
          GoToNewLine := False;
          {CurPosPixel := tbX2LeftMargin[NewDocked];
          //x2nie:
          if NewDockType <> dtLeftRight then
            Inc(CurPosPixel, CR.Left)//x2nie
          else
            Inc(CurPosPixel, CR.Top);//x2nie}
          CurPosPixel := MinPosPixels; //x2nie

          if (G <> 0) and (PGroupInfo(GInfo[G-1])^.Members.Count <> 0) then begin
            Inc (CurLinePixel, CurBarSize + tbX2LineSpacing);
            if Assigned(PreviousSep) then begin
              MinPosPixels := PrevMinPosPixels;
              if CanMoveControls then begin
                PreviousSep.Width := 0;

                LongInt(NewLineSep) := 0;
                NewLineSep.Y := CurLinePixel;
                NewLineSep.Blank := PreviousSep.Blank;
                LineSeps.Add (Pointer(@NewLineSep));
              end;
            end;
          end;
        end;
        if CurPosPixel > MinPosPixels
          then MinPosPixels := CurPosPixel;
        for I := 0 to GI^.Members.Count-1 do begin
          Member := TControl(GI^.Members[I]);
          MemberIsSep := Member is TToolbarSepX2;
          with Member do begin
            if not MemberIsSep then begin
              if NewDockType <> dtLeftRight then
                MemberPosSize := Width
              else
                MemberPosSize := Height;
            end
            else begin
              if NewDockType <> dtLeftRight then
                MemberPosSize := TToolbarSepX2(Member).SizeHorz
              else
                MemberPosSize := TToolbarSepX2(Member).SizeVert;
            end;
            { If RightX is passed, proceed to next line }
            if AllowWrap and not MemberIsSep and
               (CurPosPixel+MemberPosSize+tbX2RightMargin[NewDocked] > RightX) then begin
              {CurPosPixel := tbX2LeftMargin[NewDocked];
              //x2nie:
              if NewDockType <> dtLeftRight then
                Inc(CurPosPixel, CR.Left)//x2nie
              else
                Inc(CurLinePixel, CR.Top);//x2nie}
              CurPosPixel := MinPosPixels; //x2nie

              Inc (CurLinePixel, CurBarSize);
              GoToNewLine := True;
            end;
            if NewDockType <> dtLeftRight then begin
              //if GoToNewLine then
              //Inc(CurPosPixel, CR.Left);//x2nie:
              if not MemberIsSep then begin
                if CanMoveControls then
                  SetBounds (CurPosPixel, CurLinePixel+((DockRowSize-Height) div 2), Width, Height);
                Inc (CurPosPixel, Width);
              end
              else begin
                if CanMoveControls then
                  SetBounds (CurPosPixel, CurLinePixel, TToolbarSepX2(Member).SizeHorz, DockRowSize);
                Inc (CurPosPixel, TToolbarSepX2(Member).SizeHorz);
              end;
            end
            else begin
              //if GoToNewLine then
              //Inc(CurPosPixel, CR.Top);//x2nie:
              if not MemberIsSep then begin
                if CanMoveControls then
                  SetBounds (CurLinePixel+((DockRowSize-Width) div 2), CurPosPixel, Width, Height);
                Inc (CurPosPixel, Height);
              end
              else begin
                if CanMoveControls then
                  SetBounds (CurLinePixel, CurPosPixel, DockRowSize, TToolbarSepX2(Member).SizeVert);
                Inc (CurPosPixel, TToolbarSepX2(Member).SizeVert);
              end;
            end;
            PrevMinPosPixels := MinPosPixels;
            if not MemberIsSep then
              PreviousSep := nil
            else
              PreviousSep := TToolbarSepX2(Member);
            if CurPosPixel > MinPosPixels then MinPosPixels := CurPosPixel;
          end;
        end;
      end;
    end
    else
      Inc (MinPosPixels, tbX2DefaultBarWidthHeight);

    if csDesigning in ComponentState then
      Invalidate;
  finally
    if not CanMoveControls then begin
      FreeGroupInfo (GInfo);
      GInfo.Free;
    end;
  end;

  Inc (MinPosPixels, tbX2RightMargin[NewDocked]);
  MinRowPixels := CurLinePixel + CurBarSize + tbX2BottomMargin[NewDocked];
  if NewDockType <> dtLeftRight then begin
    Result.X := MinPosPixels - CR.Left;
    Result.Y := MinRowPixels - CR.Top;
  end
  else begin
    Result.X := MinRowPixels - CR.Left;
    Result.Y := MinPosPixels - CR.Top;
  end;

end;


procedure TCustomToolbarX2.SetControlVisible(const Control: TControl;
  const LeftOrRight: Boolean);
{ If Control is a master or slave control, it automatically adjusts the
  Visible properties of both the master and slave control based on the value
  of LeftOrRight }
var
  I: Integer;
begin
  for I := 0 to SlaveInfo.Count-1 do
    with PSlaveInfo(SlaveInfo[I])^ do
      if (TopBottom = Control) or (LeftRight = Control) then begin
        if Assigned(TopBottom) then TopBottom.Visible := not LeftOrRight;
        if Assigned(LeftRight) then LeftRight.Visible := LeftOrRight;
        Exit;
      end;

end;

procedure TCustomToolbarX2.SetSlaveControl(const ATopBottom,
  ALeftRight: TControl);
var
  NewVersion: PSlaveInfo;
begin
  GetMem (NewVersion, SizeOf(TSlaveInfo));
  with NewVersion^ do begin
    TopBottom := ATopBottom;
    LeftRight := ALeftRight;
  end;
  SlaveInfo.Add (NewVersion);
  ArrangeControls;

end;

function TCustomToolbarX2.ShouldControlBeVisible(const Control: TControl;
  const LeftOrRight: Boolean): Boolean;
{ If Control is a master or slave control, it returns the appropriate visibility
  setting based on the value of LeftOrRight, otherwise it simply returns the
  current Visible setting }
var
  I: Integer;
begin
  for I := 0 to SlaveInfo.Count-1 do
    with PSlaveInfo(SlaveInfo[I])^ do
      if TopBottom = Control then begin
        Result := not LeftOrRight;
        Exit;
      end
      else
      if LeftRight = Control then begin
        Result := LeftOrRight;
        Exit;
      end;
  Result := ControlVisibleOrDesigning(Control);
end;

{ TToolbarSep97 }

constructor TToolbarSepX2.Create (AOwner: TComponent);
begin
  inherited;
  FSizeHorz := 6;
  FSizeVert := 6;
  ControlStyle := ControlStyle - [csOpaque, csCaptureMouse];
end;

procedure TToolbarSepX2.SetParent (AParent: TWinControl);
begin
  if (AParent <> nil) and not(AParent is TCustomToolbarX2) then
    raise EInvalidOperation.Create(STBX2SepParentNotAllowed);
  inherited;
end;

procedure TToolbarSepX2.SetBlank (Value: Boolean);
begin
  if FBlank <> Value then begin
    FBlank := Value;
    Invalidate;
  end;
end;

procedure TToolbarSepX2.SetSizeHorz (Value: TToolbarSepSize);
begin
  if FSizeHorz <> Value then begin
    FSizeHorz := Value;
    if Parent is TCustomToolbarX2 then
      TCustomToolbarX2(Parent).ArrangeControls;
  end;
end;

procedure TToolbarSepX2.SetSizeVert (Value: TToolbarSepSize);
begin
  if FSizeVert <> Value then begin
    FSizeVert := Value;
    if Parent is TCustomToolbarX2 then
      TCustomToolbarX2(Parent).ArrangeControls;
  end;
end;

procedure TToolbarSepX2.Paint;
var
  R: TRect;
  Z: Integer;
begin
  inherited;
  if not(Parent is TCustomToolbarX2) then Exit;

  with Canvas do begin
    { Draw dotted border in design mode }
    if csDesigning in ComponentState then begin
      Pen.Style := psDot;
      Pen.Color := clBtnShadow;
      Brush.Style := bsClear;
      R := ClientRect;
      Rectangle (R.Left, R.Top, R.Right, R.Bottom);
      Pen.Style := psSolid;
    end;

    if not FBlank then
      if GetDockTypeOf(TCustomToolbarX2(Parent).DockedTo) <> dtLeftRight then begin
        Z := Width div 2;
        Pen.Color := clBtnShadow;
        MoveTo (Z-1, 0);  LineTo (Z-1, Height);
        Pen.Color := clBtnHighlight;
        MoveTo (Z, 0);  LineTo (Z, Height);
      end
      else begin
        Z := Height div 2;
        Pen.Color := clBtnShadow;
        MoveTo (0, Z-1);  LineTo (Width, Z-1);
        Pen.Color := clBtnHighlight;
        MoveTo (0, Z);  LineTo (Width, Z);
      end;
  end;
end;

procedure TToolbarSepX2.MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  if not(Parent is TCustomToolbarX2) then Exit;

  { Relay the message to the parent toolbar }
  P := Parent.ScreenToClient(ClientToScreen(Point(X, Y)));
  TCustomToolbarX2(Parent).MouseDown (Button, Shift, P.X, P.Y);
end;



end.
