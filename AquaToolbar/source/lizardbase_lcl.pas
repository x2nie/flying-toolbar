unit LizardBase_LCL;

{$I Lizard_Ver.inc}

interface

uses Controls, ExtCtrls;

type

  { TLzbPanel }

  TLzbPanel = class(TCustomControl)
  protected
    procedure Paint; override;
    procedure PaintSurface(); virtual; //unity, because another backend may have override paint
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

end.

