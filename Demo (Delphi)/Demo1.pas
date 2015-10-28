unit Demo1;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, StdCtrls, ExtCtrls, ComCtrls, Menus, Dialogs,
  TBx2, TBx2_Toolbar, TBx2_Button,
  ToolWin, Buttons, ImgList;

type
  TDemoForm = class(TForm)
    Memo: TMemo;
    ToolbarPopupMenu: TPopupMenu;
    TopDock: TDockX2;
    MainMenu: TMainMenu;
    FMenu: TMenuItem;
    VMenu: TMenuItem;
    EditToolbar: TToolbarX2;
    BottomDock: TDockX2;
    StatusBar: TStatusBar;
    LeftButton: TToolbarButtonX2;
    CenterButton: TToolbarButtonX2;
    RightButton: TToolbarButtonX2;
    VToolbars: TMenuItem;
    VTMain: TMenuItem;
    VTEdit: TMenuItem;
    TPMain: TMenuItem;
    TPEdit: TMenuItem;
    FExit: TMenuItem;
    LeftDock: TDockX2;
    RightDock: TDockX2;
    MainToolbar: TToolbarX2;
    FontButton: TToolbarButtonX2;
    VStatusBar: TMenuItem;
    EditSep1: TToolbarSepX2;
    SampleToolbar: TToolbarX2;
    SampleEdit1: TEditX2;
    SampleEdit2: TEditX2;
    TPSample: TMenuItem;
    VTSample: TMenuItem;
    SampleSep1: TToolbarSepX2;
    DropdownButton: TToolbarButtonX2;
    DropPopupMenu: TPopupMenu;
    Sample1: TMenuItem;
    dropdown1: TMenuItem;
    menu1: TMenuItem;
    UndoButton: TToolbarButtonX2;
    RedoButton: TToolbarButtonX2;
    SampleSep2: TToolbarSepX2;
    ToolWinButton: TToolbarButtonX2;
    cbbFont: TComboBox;
    ToolbarX21: TToolbarX2;
    ToolbarButtonX21: TToolbarButtonX2;
    ToolbarButtonX22: TToolbarButtonX2;
    ToolbarButtonX23: TToolbarButtonX2;
    ToolbarSepX21: TToolbarSepX2;
    ToolbarButtonX24: TToolbarButtonX2;
    ToolbarButtonX25: TToolbarButtonX2;
    ToolbarSepX22: TToolbarSepX2;
    ToolbarButtonX26: TToolbarButtonX2;
    ToolbarButtonX27: TToolbarButtonX2;
    ToolbarButtonX28: TToolbarButtonX2;
    ilMenus: TImageList;
    ToolbarButtonX29: TToolbarButtonX2;
    ToolbarX22: TToolbarX2;
    ToolbarButtonX210: TToolbarButtonX2;
    ToolbarButtonX211: TToolbarButtonX2;
    ToolbarButtonX212: TToolbarButtonX2;
    ToolbarX23: TToolbarX2;
    ToolbarButtonX213: TToolbarButtonX2;
    ToolbarButtonX214: TToolbarButtonX2;
    ToolbarButtonX215: TToolbarButtonX2;
    ToolbarX24: TToolbarX2;
    ToolbarButtonX216: TToolbarButtonX2;
    ToolbarButtonX217: TToolbarButtonX2;
    ToolbarButtonX218: TToolbarButtonX2;
    ToolbarX25: TToolbarX2;
    ToolbarButtonX219: TToolbarButtonX2;
    ToolbarButtonX220: TToolbarButtonX2;
    ToolbarSepX23: TToolbarSepX2;
    ToolbarButtonX222: TToolbarButtonX2;
    ToolbarButtonX223: TToolbarButtonX2;
    ToolbarSepX24: TToolbarSepX2;
    ToolbarButtonX226: TToolbarButtonX2;
    procedure FExitClick(Sender: TObject);
    procedure VTMainClick(Sender: TObject);
    procedure VTEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure VStatusBarClick(Sender: TObject);
    procedure VMenuClick(Sender: TObject);
    procedure VTSampleClick(Sender: TObject);
    procedure ToolbarPopupMenuPopup(Sender: TObject);
    procedure AddButtonClick(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure SampleToolWindowVisibleChanged(Sender: TObject);
    procedure ToolWinButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DemoForm: TDemoForm;

implementation

{$R *.DFM}

procedure TDemoForm.FormCreate(Sender: TObject);
begin
  Memo.WordWrap := True;

  { Use the SetSlaveControl method of a TToolbar97 to configure a separate
    top/bottom docked and left/right docked version of a control.
    Please see the Toolbar97 documentation for more info on slave controls.

    The line below tells it that FontCombo is the top/bottom docked version,
    and FontButton is the left/right docked version. }
  EditToolbar.SetSlaveControl (cbbFont, FontButton);
end;

procedure TDemoForm.FExitClick(Sender: TObject);
begin
  Close;
end;

procedure TDemoForm.ToolbarPopupMenuPopup(Sender: TObject);
begin
  TPMain.Checked := MainToolbar.Visible;
  TPEdit.Checked := EditToolbar.Visible;
  TPSample.Checked := SampleToolbar.Visible;
end;

procedure TDemoForm.VMenuClick(Sender: TObject);
begin
  VStatusBar.Checked := StatusBar.Visible;
  VTMain.Checked := MainToolbar.Visible;
  VTEdit.Checked := EditToolbar.Visible;
  VTSample.Checked := SampleToolbar.Visible;
end;

procedure TDemoForm.VTMainClick(Sender: TObject);
begin
  MainToolbar.Visible := not MainToolbar.Visible;
end;
procedure TDemoForm.VTEditClick(Sender: TObject);
begin
  EditToolbar.Visible := not EditToolbar.Visible;
end;
procedure TDemoForm.VTSampleClick(Sender: TObject);
begin
  SampleToolbar.Visible := not SampleToolbar.Visible;
end;

procedure TDemoForm.VStatusBarClick(Sender: TObject);
begin
  { Force the StatusBar to always be at the bottom of the form. Without this
    line of code, the status bar sometimes may appear above the bottom dock.
    This is not a bug in Toolbar97, but rather is due to the design of the
    VCL's alignment system. }
  StatusBar.Top := ClientHeight;

  { Toggle the status bar's visibility }
  StatusBar.Visible := not StatusBar.Visible;
end;

procedure TDemoForm.FontButtonClick(Sender: TObject);
begin
  ShowMessage ('A font dialog could come up here.');
end;

procedure TDemoForm.ToolWinButtonClick(Sender: TObject);
begin
//  SampleToolWindow.Visible := ToolWinButton.Down;
end;

procedure TDemoForm.SampleToolWindowVisibleChanged(Sender: TObject);
begin
//  ToolWinButton.Down := SampleToolWindow.Visible;
end;

procedure TDemoForm.ListBoxClick(Sender: TObject);
begin
//  DeleteButton.Enabled := ListBox.ItemIndex <> -1;
end;

procedure TDemoForm.AddButtonClick(Sender: TObject);
begin
//  ListBox.Items.Add (IntToStr(Random(10000)));
end;

procedure TDemoForm.DeleteButtonClick(Sender: TObject);
var
  SaveItemIndex: Integer;
begin
{  SaveItemIndex := ListBox.ItemIndex;
  ListBox.Items.Delete (ListBox.ItemIndex);
  ListBox.ItemIndex := SaveItemIndex;
  DeleteButton.Enabled := ListBox.ItemIndex <> -1;}
  
end;

end.
