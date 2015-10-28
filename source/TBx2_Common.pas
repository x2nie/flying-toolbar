unit TBx2_Common;
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

  Internal common functions

}

interface

{$I TBx2_Ver.inc}

uses
  Windows, Classes,
  {$IFDEF FPC}
  LMessages, {$ELSE}
  Messages, {$ENDIF}
  Controls;

type
  THookProcCode = (hpSendActivateApp, hpSendWindowPosChanged, hpPreDestroy,
    hpPostMouseMove);

  TListSortExCompare = function(const Item1, Item2, ExtraData: Pointer): Integer;
  TGetToolbarDockPosType = (gtpTop, gtpBottom, gtpLeft, gtpRight, gtpNone);

  TArrayOfTSmallPoint = array of TSmallPoint;

var
  GetToolbarDockPosProc: function(Ctl: TControl): TGetToolbarDockPosType = nil;
  
procedure ListSortEx (const List: TList; const Compare: TListSortExCompare;
  const ExtraData: Pointer); overload;
procedure ListSortEx (const List: TArrayOfTSmallPoint; const Compare: TListSortExCompare;
  const ExtraData: Pointer); overload;
function ApplicationIsActive: Boolean;

implementation

function ApplicationIsActive: Boolean;
{ Returns True if the application is in the foreground }
begin
  Result := GetActiveWindow <> 0;
end;

procedure ListSortEx (const List: TArrayOfTSmallPoint; const Compare: TListSortExCompare;
  const ExtraData: Pointer);
{ Similar to TList.Sort, but lets you pass a user-defined ExtraData pointer }
  procedure QuickSortEx (L: Integer; const R: Integer);
  var
    I, J: Integer;
    T, P: TSmallPoint;
  begin
    repeat
      I := L;
      J := R;
      P := List[(L + R) shr 1];
      repeat
        while Compare(@List[I], @P, ExtraData) < 0 do Inc(I);
        while Compare(@List[J], @P, ExtraData) > 0 do Dec(J);
        if I <= J then
        begin
          //List.Exchange (I, J);
          T := List[I];
          List[I] := List[J];
          List[J] := T;
          Inc (I);
          Dec (J);
        end;
      until I > J;
      if L < J then QuickSortEx (L, J);
      L := I;
    until I >= R;
  end;
begin
  if Length(List) > 1 then
    QuickSortEx (0, High(List) );
end;

procedure ListSortEx (const List: TList; const Compare: TListSortExCompare;
  const ExtraData: Pointer);
{ Similar to TList.Sort, but lets you pass a user-defined ExtraData pointer }
  procedure QuickSortEx (L: Integer; const R: Integer);
  var
    I, J: Integer;
    P: Pointer;
  begin
    repeat
      I := L;
      J := R;
      P := List[(L + R) shr 1];
      repeat
        while Compare(List[I], P, ExtraData) < 0 do Inc(I);
        while Compare(List[J], P, ExtraData) > 0 do Dec(J);
        if I <= J then
        begin
          List.Exchange (I, J);
          Inc (I);
          Dec (J);
        end;
      until I > J;
      if L < J then QuickSortEx (L, J);
      L := I;
    until I >= R;
  end;
begin
  if List.Count > 1 then
    QuickSortEx (0, List.Count-1);
end;

end.
