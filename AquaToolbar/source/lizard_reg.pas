unit Lizard_Reg;

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

{$I Lizard_Ver.inc}

uses
  Classes, TypInfo,
{$IFDEF FPC}
  LCLIntf, LResources //,LazIDEIntf, PropEdits, ComponentEditors
{$ELSE}
  {$IFDEF TB97D6} DesignIntf, DesignEditors {$ELSE} DsgnIntf {$ENDIF}
{$ENDIF};

procedure Register;

implementation

uses
  Lizard, Lizard_Toolbar;

procedure Register;
begin
  RegisterComponents('Lizard',[TDockX2, TToolbarX2 {, TToolbarButtonX2, TToolbarSepX2, TEditX2} ]);
end;

end.
