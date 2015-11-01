unit LizardConst;

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

const
  { TDockX2 exception messages }
  STBx2DockParentNotAllowed = 'A TDockX2 control cannot be placed inside a tool window or another TDockX2';
  STBx2DockCannotChangePosition = 'Cannot change Position of a TDockX2 if it already contains controls';

  { TCustomToolWindowX2 exception messages }
  STBx2ToolwinNameNotSet = 'Cannot save tool window''s position because Name property is not set';
  STBx2ToolwinDockedToNameNotSet = 'Cannot save tool window''s position because DockedTo''s Name property not set';
  STBx2ToolwinParentNotAllowed = 'A tool window can only be placed on a TDockX2 or directly on the form';

  { TCustomToolbarX2 exception messages }
  STBx2ToolbarControlNotChildOfToolbar = 'Control ''%s'' is not a child of the toolbar';

  { TToolbarSepX2 exception messages }
  STBx2SepParentNotAllowed = 'TToolbarSepX2 can only be placed on a TToolbarX2';

implementation

end.

