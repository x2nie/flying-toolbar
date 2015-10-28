{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TBx2_Lazarus;

interface

uses
  TBx2_Reg, TBx2_Toolbar, TBx2, TBx2_Common, TBx2_Const, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('TBx2_Reg', @TBx2_Reg.Register);
end;

initialization
  RegisterPackage('TBx2_Lazarus', @Register);
end.
