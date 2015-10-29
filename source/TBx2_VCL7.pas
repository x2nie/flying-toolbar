unit TBx2_VCL7;

interface
uses ExtCtrls;

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

end.
