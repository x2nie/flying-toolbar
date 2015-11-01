unit Lizard_Toolbar;

//{$ifdef fpc}{$mode delphi}{$endif}{$H+}
{$I Lizard_Ver.inc}

interface

uses
  {$IFDEF FPC}
    LCLIntf, LCLType, LMessages, Types, messages,
  {$ELSE}
    Windows, Messages,
  {$ENDIF}
    Classes, Controls, SysUtils, Graphics,
  Lizard;

type
  TToolbarParams = record
    InitializeOrderByPosition, DesignOrderByPosition: Boolean;
  end;

  { TCustomToolbarX2 }

  TCustomToolbarX2 = class(TCustomToolWindowX2)
  private
  public
  public
    constructor Create(AOwner: TComponent); override;
  end;


  TToolbarX2 = class(TCustomToolbarX2)
  published
    property Caption;
    property Color;
    property CloseButton;
    property CloseButtonWhenDocked;
  end;
implementation

{ TCustomToolbarX2 }

constructor TCustomToolbarX2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Cursor := crSize;
end;

end.

