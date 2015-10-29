object DemoForm: TDemoForm
  Left = 630
  Height = 337
  Top = 194
  Width = 453
  Caption = 'ToolbarX2 Demo'
  ClientHeight = 317
  ClientWidth = 453
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Menu = MainMenu
  OnCreate = FormCreate
  LCLVersion = '1.4.4.0'
  object TopDock: TDockX2
    Left = 0
    Height = 104
    Top = 0
    Width = 453
    object EditToolbar: TToolbarX2
      Cursor = crSizeAll
      Left = 0
      Height = 26
      Top = 26
      Width = 258
      Caption = 'Edit'
      Color = clLime
      DockPos = 0
      DockRow = 1
      ParentShowHint = False
      PopupMenu = ToolbarPopupMenu
      ShowHint = True
      TabOrder = 1
      object FontButton: TToolbarButtonX2
        Left = 13
        Height = 22
        Hint = 'Font'
        Top = 2
        Width = 23
        ImageIndex = 0
        OnClick = FontButtonClick
      end
      object EditSep1: TToolbarSepX2
        Left = 181
        Top = 2
      end
      object LeftButton: TToolbarButtonX2
        Left = 187
        Height = 22
        Hint = 'Align Left'
        Top = 2
        Width = 23
        GroupIndex = 1
        Down = True
        ImageIndex = 0
      end
      object CenterButton: TToolbarButtonX2
        Left = 210
        Height = 22
        Hint = 'Align Center'
        Top = 2
        Width = 23
        GroupIndex = 1
        ImageIndex = 0
      end
      object RightButton: TToolbarButtonX2
        Left = 233
        Height = 22
        Hint = 'Align Right'
        Top = 2
        Width = 23
        GroupIndex = 1
        ImageIndex = 0
      end
      object cbbFont: TComboBox
        Left = 36
        Height = 21
        Top = 2
        Width = 145
        ItemHeight = 13
        TabOrder = 0
        Text = 'cbbFont'
      end
    end
    object SampleToolbar: TToolbarX2
      Cursor = crSizeAll
      Left = 0
      Height = 26
      Top = 52
      Width = 316
      Caption = 'Sample'
      Color = clFuchsia
      CloseButtonWhenDocked = True
      DockPos = 0
      DockRow = 2
      ParentShowHint = False
      PopupMenu = ToolbarPopupMenu
      ShowHint = True
      TabOrder = 2
      object SampleSep1: TToolbarSepX2
        Left = 124
        Top = 2
      end
      object DropdownButton: TToolbarButtonX2
        Left = 130
        Height = 22
        Top = 2
        Width = 68
        DropdownMenu = DropPopupMenu
        Caption = 'Dropdown'
        ImageIndex = 0
      end
      object SampleSep2: TToolbarSepX2
        Left = 198
        Top = 2
      end
      object ToolWinButton: TToolbarButtonX2
        Left = 204
        Height = 22
        Top = 2
        Width = 110
        AllowAllUp = True
        GroupIndex = 2
        Caption = 'Tool Window Sample'
        ImageIndex = 0
        OnClick = ToolWinButtonClick
      end
      object SampleEdit1: TEditX2
        Left = 16
        Height = 19
        Top = 3
        Width = 54
        TabOrder = 0
        Text = 'TEditX2'
      end
      object SampleEdit2: TEditX2
        Left = 70
        Height = 19
        Top = 3
        Width = 54
        TabOrder = 1
        Text = 'sample'
      end
    end
    object MainToolbar: TToolbarX2
      Cursor = crSizeAll
      Left = 0
      Height = 26
      Top = 78
      Width = 86
      Caption = 'Main'
      Color = clYellow
      CloseButtonWhenDocked = True
      DockPos = 0
      DockRow = 3
      DragHandleStyle = dhSingle
      ParentShowHint = False
      PopupMenu = ToolbarPopupMenu
      ShowHint = True
      TabOrder = 0
      object UndoButton: TToolbarButtonX2
        Left = 16
        Height = 22
        Hint = 'Undo'
        Top = 2
        Width = 34
        DropdownCombo = True
        DropdownMenu = DropPopupMenu
        ImageIndex = 0
      end
      object RedoButton: TToolbarButtonX2
        Left = 50
        Height = 22
        Hint = 'Redo'
        Top = 2
        Width = 34
        DropdownCombo = True
        DropdownMenu = DropPopupMenu
        ImageIndex = 0
      end
    end
    object ToolbarX21: TToolbarX2
      Cursor = crSizeAll
      Left = 0
      Height = 26
      Top = 0
      Width = 208
      Caption = 'Main'
      Color = clAqua
      DockPos = 0
      DragHandleStyle = dhSingle
      ParentShowHint = False
      PopupMenu = ToolbarPopupMenu
      Resizable = False
      ShowHint = True
      TabOrder = 3
      object ToolbarButtonX21: TToolbarButtonX2
        Left = 10
        Height = 22
        Hint = 'New'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarButtonX22: TToolbarButtonX2
        Left = 33
        Height = 22
        Hint = 'Open'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarButtonX23: TToolbarButtonX2
        Left = 56
        Height = 22
        Hint = 'Save'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarSepX21: TToolbarSepX2
        Left = 79
        Top = 2
      end
      object ToolbarButtonX24: TToolbarButtonX2
        Left = 85
        Height = 22
        Hint = 'Print'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarButtonX25: TToolbarButtonX2
        Left = 108
        Height = 22
        Hint = 'Print Preview'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarSepX22: TToolbarSepX2
        Left = 131
        Top = 2
      end
      object ToolbarButtonX26: TToolbarButtonX2
        Left = 137
        Height = 22
        Hint = 'Cut'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarButtonX27: TToolbarButtonX2
        Left = 160
        Height = 22
        Hint = 'Copy'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
      object ToolbarButtonX28: TToolbarButtonX2
        Left = 183
        Height = 22
        Hint = 'Paste'
        Top = 2
        Width = 23
        ImageIndex = 0
      end
    end
  end
  object LeftDock: TDockX2
    Left = 0
    Height = 181
    Top = 104
    Width = 9
    Position = dpLeft
  end
  object Memo: TMemo
    Left = 9
    Height = 181
    Top = 104
    Width = 435
    Align = alClient
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Lines.Strings = (
      'This is a demonstration of the toolbars, so most of the buttons don''t do anything when clicked. Please see the file "ToolbarX2 Documentation.htm" for information on using the ToolbarX2 components.'
      ''
      'Some things to try:'
      '? You can drag and resize the toolbars. Dock them to any side of the form or leave them floating. Notice that if you dock the Edit toolbar to the left or right side of the form, a button is used in place of the combo box (the source code shows how this was set up).'
      '? Multiple toolbars can lined up side-by-side or in rows.'
      '? Click the right button on a toolbar or dock to see its PopupMenu.'
    )
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WantTabs = True
    WordWrap = False
  end
  object RightDock: TDockX2
    Left = 444
    Height = 181
    Top = 104
    Width = 9
    Position = dpRight
  end
  object BottomDock: TDockX2
    Left = 0
    Height = 9
    Top = 285
    Width = 453
    Position = dpBottom
  end
  object StatusBar: TStatusBar
    Left = 0
    Height = 23
    Top = 294
    Width = 453
    Panels = <    
      item
        Width = 128
      end>
  end
  object ToolbarPopupMenu: TPopupMenu
    OnPopup = ToolbarPopupMenuPopup
    left = 384
    top = 64
    object TPMain: TMenuItem
      Caption = '&Main'
      Checked = True
      OnClick = VTMainClick
    end
    object TPEdit: TMenuItem
      Caption = '&Edit'
      Checked = True
      OnClick = VTEditClick
    end
    object TPSample: TMenuItem
      Caption = '&Sample'
      Checked = True
      OnClick = VTSampleClick
    end
  end
  object MainMenu: TMainMenu
    left = 352
    top = 64
    object FMenu: TMenuItem
      Caption = '&File'
      object FExit: TMenuItem
        Caption = 'E&xit'
        OnClick = FExitClick
      end
    end
    object VMenu: TMenuItem
      Caption = '&View'
      OnClick = VMenuClick
      object VToolbars: TMenuItem
        Caption = '&Toolbars'
        object VTMain: TMenuItem
          Caption = '&Main'
          OnClick = VTMainClick
        end
        object VTEdit: TMenuItem
          Caption = '&Edit'
          OnClick = VTEditClick
        end
        object VTSample: TMenuItem
          Caption = '&Sample'
          OnClick = VTSampleClick
        end
      end
      object VStatusBar: TMenuItem
        Caption = '&Status Bar'
        OnClick = VStatusBarClick
      end
    end
    object MenuItem1: TMenuItem
      Caption = 'Dump!'
      OnClick = MenuItem1Click
    end
  end
  object DropPopupMenu: TPopupMenu
    left = 320
    top = 64
    object Sample1: TMenuItem
      Caption = 'Sample'
    end
    object dropdown1: TMenuItem
      Caption = 'drop-down'
    end
    object menu1: TMenuItem
      Caption = 'menu'
    end
  end
end
