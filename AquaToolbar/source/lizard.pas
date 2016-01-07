unit Lizard;

{$I Lizard_Ver.inc}

interface

uses
{$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Types, //messages,
  LizardMessages,
{$ELSE}
  Windows, Messages,
{$ENDIF}
  Classes, Controls, Forms, SysUtils, Graphics, ExtCtrls {shape of floating offscreen},
  ImgList,


//SURFACE BACKEND
{$IFDEF FPC}
  LizardBase_LCL,
{$ELSE}
  LizardBase_VCL,
{$ENDIF}
  LizardConst;


type
  { TDockX2 }

  //TDockBoundLinesValues = (blTop, blBottom, blLeft, blRight);
  //TDockBoundLines = set of TDockBoundLinesValues;
  TDockPosition = (dpTop, dpBottom, dpLeft, dpRight);
  TDockType = (dtNotDocked, dtTopBottom, dtLeftRight);
  TDockableTo = set of TDockPosition;

  TLzCustomToolWindow = class;

  //TInsertRemoveEvent = procedure(Sender: TObject; Inserting: Boolean;
    //Bar: TLzCustomToolWindow) of object;
  TRequestDockEvent = procedure(Sender: TObject; Bar: TLzCustomToolWindow;
    var Accept: Boolean) of object;

 

  { TLzDock }

  TLzDock = class(TLzbPanel)
  private
    FPosition: TDockPosition;
    FAllowDrag: Boolean;
    
    FFixAlign: Boolean;
    FLimitToOneRow: Boolean;

    procedure SetPosition(Value: TDockPosition);
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
    procedure ChangeDockList (const Insert: Boolean; const Bar: TLzCustomToolWindow);
    procedure ChangeWidthHeight (const NewWidth, NewHeight: Integer);
    function GetDesignModeRowOf (const XY: Integer): Integer;
    function GetRowOf (const XY: Integer; var Before: Boolean): Integer;
    function GetNumberOfToolbarsOnRow (const Row: Integer;
      const NotIncluding: TLzCustomToolWindow): Integer;
    
    function HasVisibleToolbars: Boolean;
    procedure InsertRowBefore (const BeforeRow: Integer);
    procedure RemoveBlankRows;
    function ToolbarVisibleOnDock (const AToolbar: TLzCustomToolWindow): Boolean;
    procedure ToolbarVisibilityChanged (const Bar: TLzCustomToolWindow;
      const ForceRemove: Boolean);

  protected
    procedure AlignControls (AControl: TControl; var Rect: TRect); override;  

    procedure PaintSurface; override;
    procedure DockOver(Source: TDragDockObject; X, Y: Integer;
                       State: TDragState; var Accept: Boolean); override;
    procedure PositionDockRect(DragDockObject: TDragDockObject); override;
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); override;


  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override; //tcustompaintbox = public

    procedure BeginUpdate;
    procedure EndUpdate;
    destructor Destroy; override;
    //property VisibleDockClientCount: Integer read GetVisibleDockClientCount; //override
    function GetHighestRow: Integer;
    function GetRowSize (const Row: Integer;
      const DefaultToolbar: TLzCustomToolWindow): Integer;
  published
    property Color default clBtnFace;
    //property FixAlign: Boolean read FFixAlign write SetFixAlign default False;
    //property LimitToOneRow: Boolean read FLimitToOneRow write FLimitToOneRow default False;
    property Position: TDockPosition read FPosition write SetPosition default dpTop;
    property DockSite;
    property UseDockManager;
    //property OnRequestDock: TRequestDockEvent read FOnRequestDock write FOnRequestDock;
  end;


  { TLzCustomToolWindow }
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

  TLzCustomToolWindow = class(TLzbPanel)
  private
    FActivateParent, FHideWhenInactive, FCloseButton, FCloseButtonWhenDocked,
      FFullSize, FResizable, FShowCaption, FUseLastDock: Boolean;

    FDockRow: Integer;
    FDockPos: Integer;
    FDockedTo: TLzDock;
    FOnClose, FOnDockChanged, FOnDockChanging, FOnMove, FOnRecreated,
      FOnRecreating, FOnResize, FOnVisibleChanged: TNotifyEvent;
    //FOnDockChangingEx, FOnDockChangingHidden: TDockChangingExEvent;
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
    //FFloatParent: TFloatingWindowParent; { Run-time only: The actual Parent of the toolbar when it is floating }
    FCloseButtonDown: Boolean; { True if Close button is currently depressed }
    FLastDock: TLzDock;
    FBorderStyle: TBorderStyle;
    FDragHandleStyle: TDragHandleStyle;
    FDockableTo: TDockableTo;
    FDockMode: TToolWindowDockMode;
    FDefaultDock: TLzDock;
    FImageList: TCustomImageList;
    FImageChangeLink: TChangeLink;
    procedure SetDockedTo(AValue: TLzDock);
    procedure SetDockPos(AValue: Integer);
    procedure SetDockRow(AValue: Integer);
    procedure SetFullSize(AValue: Boolean);
    procedure DrawDockedNCArea;
    function IsLastDockStored: Boolean;
    procedure SetLastDock(Value: TLzDock);
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetDragHandleStyle(const Value: TDragHandleStyle);
    procedure SetCloseButtonWhenDocked(AValue: Boolean);
    procedure SetCloseButton(const Value: Boolean);
    procedure SetFloatingMode(const Value: TToolWindowFloatingMode);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetDefaultDock(const Value: TLzDock);
    //procedure DrawDraggingOutline (const DC: HDC; const NewRect, OldRect: PRect;
      //const NewDocking, OldDocking: Boolean);
    procedure SetResizable(const Value: Boolean);
    procedure SetRowsMin(const Value: Integer);
    procedure SetImagesList(const Value: TCustomImageList);
  protected
    FRowsMin: Integer;
    procedure CustomArrangeControls (const PreviousDockType: TDockType;
      const DockingTo: TLzDock; const Resize: Boolean);
    procedure GetParams (var Params: TToolWindowParams); dynamic;
    procedure GetBarSize (var ASize: Integer; const DockType: TDockType); virtual; abstract;
    function OrderControls (CanMoveControls: Boolean; PreviousDockType: TDockType;
      DockingTo: TLzDock): TPoint; virtual; abstract;
    procedure InitializeOrdering; dynamic;
    procedure ImageListChanged(Sender: TObject); virtual;

    procedure GetDockRowSize (var AHeightOrWidth: Integer);
    procedure Loaded; override;

    function IsDocked: boolean;

  protected
    FMouseDownPos : TPoint;
    procedure SetParent(AParent: TWinControl); override;
    procedure PaintSurface; override;
    procedure ArrangeControls; virtual;
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect); override;
    procedure MouseDown(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;
    function  Weight: integer;//width or height

    property LastDock: TLzDock read FLastDock write SetLastDock stored IsLastDockStored;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property CloseButton: Boolean read FCloseButton write SetCloseButton default True;
    property CloseButtonWhenDocked: Boolean read FCloseButtonWhenDocked write SetCloseButtonWhenDocked default False;
    property DefaultDock: TLzDock read FDefaultDock write SetDefaultDock;
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
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    property Docked: Boolean read FDocked;
    procedure EndUpdate;
    property DockedTo: TLzDock read FDockedTo write SetDockedTo stored False;
    property DockPos: Integer read FDockPos write SetDockPos default -1;
    property DockRow: Integer read FDockRow write SetDockRow default 0;
  published
    property DragKind;
    property DragMode;
  end;

  
  { TLzDockManager }

  TLzDockManager = class(TDockManager)
  private
     FDockSite : TLzDock;
  protected

  public
    constructor Create(ADockSite: TWinControl); override;
    procedure PositionDockRect(Client, DropCtl: TControl; DropAlign: TAlign;
                               var DockRect: TRect); override;
    procedure GetControlBounds(Control: TControl;
                               out AControlBounds: TRect); override;
    procedure InsertControl(Control: TControl; InsertAt: TAlign;
                            DropCtl: TControl); override;
    procedure LoadFromStream(Stream: TStream); override;

    procedure RemoveControl(Control: TControl); override;
    procedure ResetBounds(Force: Boolean); override;
    procedure SaveToStream(Stream: TStream); override;
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

function GetDockTypeOf (const Control: TLzDock): TDockType;
///function GetToolWindowParentForm (const ToolWindow: TCustomToolWindowX2):  {$IFDEF TB97D3} TCustomForm {$ELSE} TForm {$ENDIF};

implementation
uses
  Lizard_Common ;

const

  DefaultBarWidthHeight = 8;

  ForceDockAtTopRow = 0;
  ForceDockAtLeftPos = -8;


var
  FloatingToolWindows: TList = nil;
  //UFloatingDragWindow :  TFloatingDragWindow = nil;

function GetDockedCloseButtonRect (const Control: TLzCustomToolWindow;
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

function GetDockTypeOf (const Control: TLzDock): TDockType;
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


{ TLzDock }

function CompareDockRowPos (const Item1, Item2, ExtraData: Pointer): Integer; far;
begin
  if TLzCustomToolWindow(Item1).FDockRow <> TLzCustomToolWindow(Item2).FDockRow then
    Result := TLzCustomToolWindow(Item1).FDockRow - TLzCustomToolWindow(Item2).FDockRow
  else
    Result := TLzCustomToolWindow(Item1).FDockPos - TLzCustomToolWindow(Item2).FDockPos;
end;

procedure TLzDock.AlignControls(AControl: TControl; var Rect: TRect);
begin
  ArrangeToolbars (False);
end;

procedure TLzDock.ArrangeToolbars(const ClipPoses: Boolean);
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
  T: TLzCustomToolWindow;
  NewDockPos: PIntegerArray;
  MultiRow : TList;

  procedure ArrangeNoOverlaped(FirstRow, LastRow: Integer; UntilBar:Integer = -1);
  { Adjust DockPos's of toolbars to make sure none of the them overlap }
  var
    LCurrentRow,I,J,K,Z: Integer;
    M,T: TLzCustomToolWindow;
  begin
    //for LCurrentRow := 0 to HighestRow do begin
    for LCurrentRow := FirstRow to LastRow do begin
      CurDockPos := 0;
      Z := DockList.Count-1;
      if (LCurrentRow = LastRow) and (UntilBar > -1) then
        Z := UntilBar;
      for I := 0 to Z do begin
        T := TLzCustomToolWindow(DockList[I]);
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
                  M := TLzCustomToolWindow(MultiRow[J]);
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
    M,T: TLzCustomToolWindow;
    
      procedure CompactFromRight(FirstBar,LastBar: Integer);
      var
        CurDockPos,
        I,J,K,Z: Integer;
        M,T: TLzCustomToolWindow;
      begin
        if not LeftRight then
          CurDockPos := ClientW
        else
          CurDockPos := ClientH;
        //for I := DockList.Count-1 downto 0 do begin
        for I := FirstBar downto LastBar do begin
          T := TLzCustomToolWindow(DockList[I]);
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
                  M := TLzCustomToolWindow(MultiRow[J]);
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
        M,T: TLzCustomToolWindow;
      begin
        CurDockPos := 0;
        //for I := 0 to DockList.Count-1 do begin
        for I := FirstBar to LastBar do begin
          T := TLzCustomToolWindow(DockList[I]);
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
                  M := TLzCustomToolWindow(MultiRow[J]);
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
                  M := TLzCustomToolWindow(MultiRow[J]);
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
      EmptySize := Ord(FFixAlign)+100;//debug
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
        with TLzCustomToolWindow(DockList[I]) do
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
        with TLzCustomToolWindow(DockList[I]) do
          if (FDockRow = LCurrentRow) and FullSize then
            for J := 0 to DockList.Count-1 do
              if (J <> I) and (TLzCustomToolWindow(DockList[J]).FDockRow = LCurrentRow) then begin
                for K := 0 to DockList.Count-1 do
                  with TLzCustomToolWindow(DockList[K]) do
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
      with TLzCustomToolWindow(DockList[K]) do
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
        NewDockPos[I] := TLzCustomToolWindow(DockList[I]).FDockPos;

      { Move toolbars (to left) that go off the edge of the dock to a fully visible
        position if possible }
      ArrangeCompacting(0, HighestRow);

      { If FArrangeToolbarsClipPoses (ClipPoses) is True, update all the
        toolbars' DockPos's to match the actual positions }
      if FArrangeToolbarsClipPoses then
        for I := 0 to DockList.Count-1 do
          TLzCustomToolWindow(DockList[I]).FDockPos := NewDockPos[I];

      { Now actually move the toolbars }
      CurRowPixel := 0;
      for LCurrentRow := 0 to HighestRow do begin
        CurRowSize := Longint(RowSizes[LCurrentRow]);
        if CurRowSize <> 0 then
          Inc (CurRowSize, DockedBorderSize2);
        for I := 0 to DockList.Count-1 do begin
          T := TLzCustomToolWindow(DockList[I]);
          with T do
            if (FDockRow = LCurrentRow)
            and ToolbarVisibleOnDock(T) then begin
              {$ifdef fpc}
              DisableAutoSizing;
              try
              {$endif}
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
              {$ifdef fpc}
              finally
                EnableAutoSizing;
              end;
              {$endif}
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

procedure TLzDock.BeginUpdate;
begin
  Inc (FDisableArrangeToolbars);
end;

procedure TLzDock.BuildRowInfo;
var
  R, I, Size, HighestSize: Integer;
  ToolbarOnRow: Boolean;
  T: TLzCustomToolWindow;
begin
  RowSizes.Clear;
  for R := 0 to GetHighestRow do begin
    ToolbarOnRow := False;
    HighestSize := 0;
    for I := 0 to DockList.Count-1 do begin
      T := TLzCustomToolWindow(DockList[I]);
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

procedure TLzDock.ChangeDockList(const Insert: Boolean;
  const Bar: TLzCustomToolWindow);
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

procedure TLzDock.ChangeWidthHeight(const NewWidth, NewHeight: Integer);
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

constructor TLzDock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls] -
    [csClickEvents, csCaptureMouse, csOpaque];
  FAllowDrag := True;
  //FBkgOnToolbars := True;
  DockList := TList.Create;
  DockVisibleList := TList.Create;
  RowSizes := TList.Create;

  Color := clBtnFace;
  Position := dpTop;
  TLzDockManager.Create(Self);
  DockSite := True;
end;


destructor TLzDock.Destroy;
begin
  {$ifndef fpc}
  if (DockManager<>nil) and (TDockManager(DockManager) is TLzDockManager)
  and TLzDockManager(DockManager).AutoFreeByControl then
    TLzDockManager(DockManager).Free;
  {$endif}

  DockManager:=nil;
  inherited;
end;

procedure TLzDock.DoAddDockClient(Client: TControl; const ARect: TRect);
begin
  if Client.Parent <> self Then
    inherited DoAddDockClient(Client, ARect);
  //Client.Align := alTop;
  //Client.Align := AlNone;
  Client.Align := alCustom;
  with Arect do
  Client.SetBounds(Left, Top, Right-Left, Bottom-TOp);
end;

procedure TLzDock.DockOver(Source: TDragDockObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var R,r2 :TRect;
  P : TPoint;
begin

  Accept := Source.Control is TLzCustomToolWindow;
  inherited DockOver(Source, X, Y, State, Accept);
  {if Accept then begin
    Source.DropAlign:=alTop;
    R2 := source.Control.BoundsRect;

    //R.TopLeft
    P := ClientToScreen(Point(X,Y));
    OffsetRect(R2,P.X,P.Y);

    P := Source.DockOffset;
    OffsetRect(R2,-P.X,-P.Y);

    R.Right := R.Left+36;
    R.Bottom:= R.Top+26;

    Source.DockRect :=  R2;

  end;}
  //if State = dsDragMove then    PositionDockRect(Source);
  //DoDockOver(Source, X, Y, State, Accept);
  //Writeln('TLzDock.DockOver Accept:'+ inttostr(Integer(Accept)));
end;

procedure TLzDock.PaintSurface;
var
  R, R2: TRect;
  P1, P2: TPoint;
begin
  inherited PaintSurface;
  //Buffer.Clear(Color32(self.Color));
  with Canvas do begin
    R := ClientRect;

    { Draw dotted border in design mode }
    if csDesigning in ComponentState then begin
      Pen.Style := psDash;
      Pen.Color := clBlack;
      Brush.Style := bsFDiagonal;
      Brush.Color := clCream;
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

procedure TLzDock.PositionDockRect(
  DragDockObject: TDragDockObject);
var
  NewWidth, NewHeight: Integer;
  TempX, TempY: Double;
  Size: TPoint;

var
  //MouseOverDock : TLzDock;
  MoveRect : TRect;
  DPoint: TPoint;
  Tb : TLzCustomToolWindow;
begin
  //Writeln('TLzDock.PositionDockRect');
  if (DragDockObject.Control is TLzCustomToolWindow) then
  with DragDockObject do begin
    Tb := TLzCustomToolWindow(Control);
    //MouseOverDock := TLzDock(DragTarget);
    //DPoint := Point(Tb.Width, Tb.Height);
    {if Position in Tb.DockableTo then
      Size := Tb.OrderControls(False, GetDockTypeOf(Tb.DockedTo), Self)
    else
      Size := Tb.ClientRect.BottomRight;}
    Size := Point(Tb.Width, Tb.Height);

    Write(Format('DragPos: %d,%d',[DragPos.x, DragPos.y]));
    Write(Format(' DragTargetPos: %d,%d',[DragTargetPos.x, DragTargetPos.y]));
    Writeln(Format(' DockRect: %d,%d',[DockRect.left, DockRect.top]));

    {$IFDEF FPC}
    TempX := DragPos.X - ((Tb.FMouseDownPos.X) );
    TempY := DragPos.Y - ((tb.FMouseDownPos.Y) );
    DragDockObject.DockRect := Bounds(Round(TempX), Round(TempY),
        Tb.Width, Tb.Height);
    {$ELSE}
    // Drag position for dock rect is scaled relative to control's click point.
    TempX := DragPos.X - ((Size.X) * MouseDeltaX);
    TempY := DragPos.Y - ((Size.Y) * MouseDeltaY);

    {MoveRect := Bounds(DragPos.X-MulDiv(Size.X-1, DragPos.X, DPoint.X),
        DragPos.Y-MulDiv(Size.Y-1, DragPos.Y, DPoint.Y),
        Size.X, Size.Y);}

    MoveRect := Bounds(Round(TempX), Round(TempY),
        Size.X, Size.Y);

    {with MoveRect do begin
      Left := DragPos.x;
      Top := DragPos.y;
      Right := Left + Size.X;
      Bottom:= Top + Size.Y;
    end;}
    // let user adjust dock rect
    //OffsetRect( MoveRect, -DockOffset.x, -DockOffset.y);
    DragDockObject.DockRect := MoveRect;
    {$ENDIF}


      //AddDockedNCAreaToSize (Size, Dock.Position in PositionLeftOrRight);
  end
  else
    inherited;
end;

procedure TLzDock.EndUpdate;
begin
  Dec (FDisableArrangeToolbars);
  if FArrangeToolbarsNeeded and (FDisableArrangeToolbars = 0) then
    ArrangeToolbars (FArrangeToolbarsClipPoses);
end;

function TLzDock.GetDesignModeRowOf(const XY: Integer): Integer;
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

function TLzDock.GetHighestRow: Integer;
{ Returns highest used row number, or -1 if no rows are used }
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DockList.Count-1 do
    with TLzCustomToolWindow(DockList[I]) do
    begin
      if (FDockRow > Result)
      then
        Result := FDockRow;

      if (RowsMin > 1) and (FDockRow + RowsMin -1 > Result)  then
          Result := FDockRow + RowsMin -1;
    end;
end;

function TLzDock.GetNumberOfToolbarsOnRow(const Row: Integer;
  const NotIncluding: TLzCustomToolWindow): Integer;
{ Returns number of toolbars on the specified row. The toolbar specified by
  "NotIncluding" is not included in the count. }
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to DockList.Count-1 do
    if (TLzCustomToolWindow(DockList[I]).FDockRow = Row) and
       (DockList[I] <> NotIncluding) then
      Inc (Result);
end;

function TLzDock.GetRowOf(const XY: Integer; var Before: Boolean): Integer;
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

function TLzDock.GetRowSize(const Row: Integer;
  const DefaultToolbar: TLzCustomToolWindow): Integer;
begin
  Result := 0;
  if Row < RowSizes.Count then
    Result := Longint(RowSizes[Row]);
  if (Result = 0) and Assigned(DefaultToolbar) then
    DefaultToolbar.GetBarSize (Result, GetDockTypeOf(Self));
end;

function TLzDock.HasVisibleToolbars: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to DockList.Count-1 do
    if ToolbarVisibleOnDock(TLzCustomToolWindow(DockList[I])) then begin
      Result := True;
      Break;
    end;
end;

procedure TLzDock.InsertRowBefore(const BeforeRow: Integer);
{ Inserts a blank row before BeforeRow, adjusting all the docked toolbars'
  FDockRow as needed }
var
  I: Integer;
begin
  for I := 0 to DockList.Count-1 do
    with TLzCustomToolWindow(DockList[I]) do
      if FDockRow >= BeforeRow then
        Inc (FDockRow);
end;

procedure TLzDock.Loaded;
begin
  inherited;
  { Rearranging is disabled while the component is loading, so now that it's
    loaded, rearrange it. }
  ArrangeToolbars (False);

end;

procedure TLzDock.RemoveBlankRows;
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
      with TLzCustomToolWindow(DockList[I]) do
      if (FDockRow = R)
      or ( (RowsMin > 1) and (R >= FDockRow) and (R <= FDockRow + RowsMin -1 ) ) 
      then begin
        RowIsEmpty := False;
        Break;
      end;


    if RowIsEmpty then begin
      { Shift all ones higher than R back one }
      for I := 0 to DockList.Count-1 do
        with TLzCustomToolWindow(DockList[I]) do
          if FDockRow > R then
            Dec (FDockRow);
      Dec (HighestRow);
    end
    else
      Inc (R);
  end;

end;

procedure TLzDock.SetFixAlign(const Value: Boolean);
begin
  if FFixAlign <> Value then begin
    FFixAlign := Value;
    ArrangeToolbars (False);
  end;
end;

procedure TLzDock.SetPosition(Value: TDockPosition);
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

procedure TLzDock.ToolbarVisibilityChanged(const Bar: TLzCustomToolWindow;
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

    //if Assigned(FOnInsertRemoveBar) then
      //FOnInsertRemoveBar (Self, VisibleOnDock, Bar);
  end;
end;

function TLzDock.ToolbarVisibleOnDock(
  const AToolbar: TLzCustomToolWindow): Boolean;
begin
  Result := (AToolbar.Parent = Self) and
    (AToolbar.Visible or (csDesigning in AToolbar.ComponentState));
end;

{ TLzCustomToolWindow }

procedure TLzCustomToolWindow.ArrangeControls;
begin
  if not (csLoading in ComponentState) then
  CustomArrangeControls (GetDockTypeOf(DockedTo), DockedTo, True);
end;

procedure TLzCustomToolWindow.BeginUpdate;
begin
  Inc (FDisableArrangeControls);
end;

procedure TLzCustomToolWindow.CustomArrangeControls(
  const PreviousDockType: TDockType; const DockingTo: TLzDock;
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
          {$IFDEF TBX2_DRAGDROP}
          DisableAutoSizing;
          try
            SetBounds (Left, Top, X, Y);
          finally
            EnableAutoSizing;
          end;
          {$ENDIF}
        end;
      end;
  finally
    Dec (FDisableArrangeControls);
  end;

end;



{function TLzDock.GetVisibleDockClientCount: Integer;
begin
  if not FControlsAsDocked then //flag run once
  begin
    FControlsAsDocked := True;
  end;
  Result := inherited VisibleDockClientCount;
end;}


{ TLzCustomToolWindow }

procedure TLzCustomToolWindow.PaintSurface;
begin
  inherited PaintSurface;
  DrawDockedNCArea;
end;

procedure TLzCustomToolWindow.DoDock(NewDockSite: TWinControl; var ARect: TRect );
begin
  //Writeln('TLzCustomToolWindow.DoDock'+ inttohex (Integer(NewDockSite),8) );
  //inherited DoDock(NewDockSite, ARect);
  if (NewDockSite = nil) then Parent := nil;
    if NewDockSite<>nil then begin
      //DebugLn('TControl.DoDock BEFORE Adjusting ',DbgSName(Self),' ',dbgs(ARect));
      // adjust new bounds, so that they at least fit into the client area of
      // its parent
      if TPanel(NewDockSite).AutoSize then begin
        case align of
          alLeft,
          alRight : ARect:=Rect(0,0,Width,NewDockSite.ClientHeight);
          alTop,
          alBottom : ARect:=Rect(0,0,NewDockSite.ClientWidth,Height);
        else
          ARect:=Rect(0,0,Width,Height);
        end;
      end else begin
        {$IFDEF fpc}
        //LCLProc.MoveRectToFit(ARect, NewDockSite.GetLogicalClientRect);
        ARect.TopLeft := NewDockSite.ScreenToClient(Arect.TopLeft);
        ARect.BottomRight := NewDockSite.ScreenToClient(Arect.BottomRight);
        {$ENDIF}
        // consider Align to increase chance the width/height is kept
        case Align of
          alLeft: OffsetRect(ARect,-ARect.Left,0);
          alTop: OffsetRect(ARect,0,-ARect.Top);
          alRight: OffsetRect(ARect,NewDockSite.ClientWidth-ARect.Right,0);
          alBottom: OffsetRect(ARect,0,NewDockSite.ClientHeight-ARect.Bottom);
        end;
      end;
      //DebugLn('TControl.DoDock AFTER Adjusting ',DbgSName(Self),' ',dbgs(ARect),' Align=',DbgS(Align),' NewDockSite.ClientRect=',dbgs(NewDockSite.ClientRect));
    end;
    //debugln('TControl.DoDock BEFORE MOVE ',Name,' BoundsRect=',dbgs(BoundsRect),' NewRect=',dbgs(ARect));
    {$IFDEF fpc}
    if Parent<>NewDockSite then
      BoundsRectForNewParent := ARect
    else {$ENDIF}
      BoundsRect := ARect;
    //debugln('TControl.DoDock AFTER MOVE ',DbgSName(Self),' BoundsRect=',dbgs(BoundsRect),' TriedRect=',dbgs(ARect));
end;

procedure TLzCustomToolWindow.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownPos := Point(X,Y);
  inherited MouseDown(Button, Shift, X, Y);
end;

function TLzCustomToolWindow.Weight: integer;
begin
  if Assigned(DockedTo) and (DockedTo.Position in PositionLeftOrRight) then
    Result := Height
  else
    Result := Width;
end;


procedure TLzCustomToolWindow.DrawDockedNCArea;
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
  if {not Docked or} not HandleAllocated then Exit;
  Canvas.Brush.Color:= clRed;
  Canvas.FillRect(Rect(0,0,10,10));
  Canvas.Brush.Color:= clYellow;
  Canvas.FrameRect(self.ClientRect);

(*
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
*)
end;

procedure TLzCustomToolWindow.EndUpdate;
begin
  Dec (FDisableArrangeControls);
  if FArrangeNeeded and (FDisableArrangeControls = 0) then
    ArrangeControls;
end;

procedure TLzCustomToolWindow.GetDockRowSize(var AHeightOrWidth: Integer);
begin
  if IsDocked then
    with DockedTo do begin
      BuildRowInfo;
      AHeightOrWidth := DockedTo.GetRowSize(FDockRow, Self);
    end
  else
    GetBarSize (AHeightOrWidth, dtNotDocked);
end;





function TLzCustomToolWindow.IsLastDockStored: Boolean;
begin
  Result := FDockedTo = nil;
end;

procedure TLzCustomToolWindow.SetCloseButtonWhenDocked(AValue: Boolean);
begin
  if FCloseButtonWhenDocked=AValue then Exit;
  FCloseButtonWhenDocked:=AValue;
  if {Docked} IsDocked then
      //RecalcNCArea (Self);
    ArrangeControls;
  Invalidate;
end;

procedure TLzCustomToolWindow.SetDockedTo(AValue: TLzDock);
begin
  if FDockedTo=AValue then Exit;
  if Assigned(AValue) then
    Parent := AValue
  {else
    Parent := ValidToolWindowParentForm(Self)};
  if Parent is TLzDock then
    FDockedTo:=TLzDock(Parent);
end;

procedure TLzCustomToolWindow.SetDockPos(AValue: Integer);
begin
  if FDockPos=AValue then Exit;
  FDockPos:=AValue;
  if IsDocked then
    DockedTo.ArrangeToolbars (False);
end;

procedure TLzCustomToolWindow.SetDockRow(AValue: Integer);
begin
  if FDockRow=AValue then Exit;
  FDockRow:=AValue;
  if IsDocked then
    DockedTo.ArrangeToolbars (False);
end;

procedure TLzCustomToolWindow.SetFullSize(AValue: Boolean);
begin
  if FFullSize=AValue then Exit;
  FFullSize:=AValue;
  ArrangeControls;
end;

procedure TLzCustomToolWindow.SetLastDock(Value: TLzDock);
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

procedure TLzCustomToolWindow.SetParent(AParent: TWinControl);
function ParentToDockedTo (const Ctl: TWinControl): TLzDock;
  begin
    if Ctl is TLzDock then
      Result := TLzDock(Ctl)
    else
      Result := nil;
  end;
var
  
  //NewFloatParent: TFloatingWindowParent;
  OldDockedTo, NewDockedTo: TLzDock;
  OldParent: TWinControl;
begin
{  if not (csDocking in ControlState) and not (csDesigning in ComponentState)then
  begin
    Dock(AParent, self.BoundsRect );
  end
  else
    inherited;
    }
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
    //UpdateFloatingToolWindows;
  end
  else begin
    if not(csDestroying in ComponentState) and Assigned(AParent) then begin
      if Assigned(FOnDockChanging) then
        FOnDockChanging (Self);
      {if Assigned(FOnDockChangingEx) then
        FOnDockChangingEx (Self, NewDockedTo);
      if Assigned(FOnRecreating) then
        FOnRecreating (Self);}
    end;

    { Before changing between docked and floating state (and vice-versa)
      or between docks, increment FHidden and call UpdateVisibility to hide the
      toolbar. This prevents any flashing while it's being moved }
    Inc (FHidden);
    Inc (FDisableOnMove);
    try
      //UpdateVisibility;
      if Assigned(OldDockedTo) then
        OldDockedTo.BeginUpdate;
      if Assigned(NewDockedTo) then
        NewDockedTo.BeginUpdate;
      DisableAutoSizing;
      try
        if Assigned(AParent) then begin
          //DoDockChangingHidden (NewDockedTo);
          { Must pre-arrange controls in new dock orientation before changing
            the Parent }
          if FLastDockTypeSet then
            CustomArrangeControls (FLastDockType, NewDockedTo, False);
        end;
        FArrangeNeeded := True;  { force EndUpdate to rearrange }
        BeginUpdate;
        try
          if Parent is TLzDock then begin
            if not FUseLastDock then
              TLzDock(Parent).ChangeDockList (False, Self);
            TLzDock(Parent).ToolbarVisibilityChanged (Self, True);
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
          //CalculateNonClientSizes (nil);

          {if OldParent is TFloatingWindowParent then begin
            if FFloatParent = OldParent then FFloatParent := nil;
            OldParent.Free;
          end;}

          if Parent is TLzDock then begin
            if FUseLastDock then begin
              LastDock := TLzDock(Parent);  { calls ChangeDockList if LastDock changes }
              TLzDock(Parent).ToolbarVisibilityChanged (Self, False);
            end
            else
              TLzDock(Parent).ChangeDockList (True, Self);
          end;

          //UpdateFloatingToolWindows;
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
      //UpdateVisibility;
      { ^ The above UpdateVisibility call not only updates the tool window's
        visibility after decrementing FHidden, it also sets the
        active/inactive state of the caption. }
    end;
    //if Assigned(Parent) then
      //Moved;

    if not(csDestroying in ComponentState) and Assigned(AParent) then begin
      if Assigned(FOnRecreated) then
        FOnRecreated (Self);
      if Assigned(FOnDockChanged) then
        FOnDockChanged (Self);
    end;
  end;
end;
procedure TLzCustomToolWindow.SetBorderStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then begin
    FBorderStyle := Value;
    //if Docked then RecalcNCArea (Self);
    Invalidate;
  end;
end;

procedure TLzCustomToolWindow.SetDragHandleStyle(
  const Value: TDragHandleStyle);
begin
  if FDragHandleStyle <> Value then begin
    FDragHandleStyle := Value;
    if IsDocked then
      //RecalcNCArea (Self);
      ArrangeControls;
    Invalidate;
  end;
end;




constructor TLzCustomToolWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle +
    [csAcceptsControls, csClickEvents, csDoubleClicks, csSetCaption] -
    [csCaptureMouse{capturing is done manually}, csOpaque];

  //BorderStyle := bsSingle;
  FDockableTo := [dpTop, dpBottom, dpLeft, dpRight];

  DragKind := dkDock;
  DragMode := dmAutomatic;

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
procedure TLzCustomToolWindow.SetCloseButton(const Value: Boolean);
begin
  if FCloseButton <> Value then begin
    FCloseButton := Value;

    { Update the close button's visibility }
    //InvalidateFloatingNCArea ([twrdCaption, twrdCloseButton]);
    Invalidate;
  end;
end;

procedure TLzCustomToolWindow.SetFloatingMode(
  const Value: TToolWindowFloatingMode);
begin
  if FFloatingMode <> Value then begin
    FFloatingMode := Value;
    if HandleAllocated then
      Perform (CM_SHOWINGCHANGED, 0, 0);
  end;
end;

procedure TLzCustomToolWindow.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then begin
    FShowCaption := Value;
    if not IsDocked then
      ///RecalcNCArea (Self);
  end;
end;

procedure TLzCustomToolWindow.SetDefaultDock(const Value: TLzDock);
begin
  if FDefaultDock <> Value then begin
    FDefaultDock := Value;
    if Assigned(Value) then
      Value.FreeNotification (Self);
  end;
end;

procedure TLzCustomToolWindow.SetResizable(const Value: Boolean);
begin
  if FResizable <> Value then begin
    FResizable := Value;
    if not IsDocked then
      { Recreate the window handle because Resizable affects whether the
        tool window is created with a WS_THICKFRAME style }
      {$IFNDEF FPC}
      RecreateWnd;
    {$ENDIF}
  end;
end;
procedure TLzCustomToolWindow.GetParams(var Params: TToolWindowParams);
begin
  with Params do begin
    CallAlignControls := True;
    ResizeEightCorner := True;
    ResizeClipCursor := True;
  end;
end;
procedure TLzCustomToolWindow.Loaded;
var
  R: TRect;
begin
  //inherited;
  // Adjust coordinates if it was initially floating
  {if not FSavedAtRunTime and not(csDesigning in ComponentState) and
     (Parent is TFloatingWindowParent) then begin
    R := BoundsRect;
    MapWindowPoints (ValidToolWindowParentForm(Self).Handle, 0, R, 2);
    BoundsRect := R;
    MoveOnScreen (False);
  end;}
  InitializeOrdering;
  // Arranging of controls is disabled while component was loading, so rearrange
    //it now
  ArrangeControls;
  inherited;
end;

function TLzCustomToolWindow.IsDocked: boolean;
begin
  result := FDockedTo <> nil;
end;

procedure TLzCustomToolWindow.InitializeOrdering;
begin

end;

procedure TLzCustomToolWindow.SetRowsMin(const Value: Integer);
begin
  if FRowsMin <> Value then
  begin
    if Value <= 0 then
      Abort;
    FRowsMin := Value;
    Parent.Realign;
  end;
end;

procedure TLzCustomToolWindow.SetImagesList(const Value: TCustomImageList);
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

procedure TLzCustomToolWindow.ImageListChanged(Sender: TObject);
begin
  Invalidate;
end;

{ TLzDockManager }

constructor TLzDockManager.Create(ADockSite: TWinControl);
begin
// Init DockSite and DragManager.
  Assert(ADockSite is TLzDock, 'Only TLzDock supported currently');
  FDockSite := TLzDock(ADockSite);
  TPanel(ADockSite).DockManager := self; //cast it because properties are protected
//reset inappropriate docking defaults - should be fixed in Controls/DragManager!
  //DragManager.DragImmediate := False;
  inherited Create(ADockSite);
end;


procedure TLzDockManager.GetControlBounds(Control: TControl;
  out AControlBounds: TRect);
begin
  inherited;

end;

procedure TLzDockManager.InsertControl(Control: TControl; InsertAt: TAlign;
  DropCtl: TControl);
begin
  inherited;

end;

procedure TLzDockManager.LoadFromStream(Stream: TStream);
begin
  inherited;

end;


procedure TLzDockManager.PositionDockRect(Client, DropCtl: TControl;
  DropAlign: TAlign; var DockRect: TRect);
var
  Offset : TPoint;
  //MouseOverDock : TLzDock;
  MoveRect : TRect;
  DPoint: TPoint;
  Tb : TLzCustomToolWindow;
  Size : TPoint;
  TempX, TempY : integer;
begin
  exit;
  //Writeln('TLzDockManager.PositionDockRect');
  //with DragDockObject do
  //begin
    //debugln(['TCustomtoolwin.PositionDockRect="',DbgSName(TControl(DragTarget))]);
    if (Client is TLzCustomToolWindow) then
    begin
      Tb := TLzCustomToolWindow(Client);
      //MouseOverDock := TLzDock(DragTarget);
      DPoint := Point(Tb.Width-1, Tb.Height-1);
      {if FDockSite.Position in Tb.DockableTo then
        Size := Tb.OrderControls(False, GetDockTypeOf(Tb.DockedTo), FDockSite)
      else
        Size := Tb.ClientRect.BottomRight;}
      Size := Point(Tb.Width, Tb.Height);

      // Drag position for dock rect is scaled relative to control's click point.
      (*{$IFNDEF FPC}
      TempX := DragPos.X - ((Size.X) * MouseDeltaX);
      TempY := DragPos.Y - ((Size.Y) * MouseDeltaY);
      {$ELSE}
      TempX := DragPos.X - ((Size.X) );
      TempY := DragPos.Y - ((Size.Y) );
      {$ENDIF}
      {$ifdef axyz}
      MoveRect := Bounds(DragPos.X-MulDiv(Size.X-1, DragPos.X, DPoint.X),
          DragPos.Y-MulDiv(Size.Y-1, DragPos.Y, DPoint.Y),
          Size.X, Size.Y);
      {$else}
      MoveRect := Bounds(Round(TempX), Round(TempY),
          Size.X, Size.Y);
      {$endif}
      DockRect := MoveRect;
      *)
      with DockRect do begin
        Right := Left + Size.X;
        Bottom := Top + Size.Y;
      end;
      //AddDockedNCAreaToSize (Size, Dock.Position in PositionLeftOrRight);
    end
    else  
    begin
      DockRect := Rect(0, 0, FDockSite.ClientWidth, FDockSite.ClientHeight);
      if (Client is TLzCustomToolWindow) then
      begin
        Tb := TLzCustomToolWindow(Client);
        DockRect := Rect(0, 0, Tb.ClientWidth, Tb.ClientHeight);
      end;
      Offset:=FDockSite.ClientOrigin;
      OffsetRect(DockRect,Offset.X,Offset.Y);
    end;
end;

procedure TLzDockManager.RemoveControl(Control: TControl);
begin
  inherited;

end;

procedure TLzDockManager.ResetBounds(Force: Boolean);
begin
  inherited;

end;

procedure TLzDockManager.SaveToStream(Stream: TStream);
begin
  inherited;

end;

end.

