{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Lizard_Lazarus;

interface

uses
  LizardConst, Lizard, Lizard_Toolbar, Lizard_Reg, Lizard_Common, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('Lizard_Reg', @Lizard_Reg.Register);
end;

initialization
  RegisterPackage('Lizard_Lazarus', @Register);
end.
