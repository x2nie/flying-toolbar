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

  TLzCustomToolbar = class(TLzCustomToolWindow)
  private
  public
  public
    constructor Create(AOwner: TComponent); override;
  end;


  TLzToolbar = class(TLzCustomToolbar)
  published
    property Caption;
    property Color;
    property CloseButton;
    property CloseButtonWhenDocked;
  end;
implementation

{ TCustomToolbarX2 }

constructor TLzCustomToolbar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Cursor := crSize;
end;

end.

