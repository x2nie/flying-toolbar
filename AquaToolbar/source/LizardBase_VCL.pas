unit LizardBase_VCL;

{$I Lizard_Ver.inc}

interface

uses ExtCtrls;

type

  { TLzbPanel }

  TLzbPanel = class(TCustomPanel)
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

