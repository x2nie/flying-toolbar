unit LizardMessages;

interface
{$IFDEF FPC}


uses
  LCLType, LCLIntf, LMessages, Types,
  //messages,
  Messages;

type
  TWMNCCalcSize = TLMNCCalcSize;
  TMessage = TLMessage;
  TWMLButtonDblClk = TLMLButtonDblClk;
  TWMCancelMode = TLMNoParams;//TLMCancelMode;
  TWMKILLFOCUS = TLMKILLFOCUS;
  TWMSetFocus = TLMSetFocus;


const
  WM_NCPAINT    = LM_NCPAINT; //LM_PAINT; //
  WM_NCCALCSIZE = LM_NCCALCSIZE;
  WM_LBUTTONDBLCLK = LM_LBUTTONDBLCLK;
  WM_MBUTTONDBLCLK = LM_MBUTTONDBLCLK;
  WM_RBUTTONDBLCLK = LM_RBUTTONDBLCLK;
  WM_LBUTTONDOWN   = LM_LBUTTONDOWN;
  WM_RBUTTONDOWN   = LM_RBUTTONDOWN;
  WM_MBUTTONDOWN   = LM_MBUTTONDOWN;


  WM_CANCELMODE = LM_CANCELMODE;
  WM_KILLFOCUS = LM_KILLFOCUS;
  WM_SETFOCUS  = LM_SETFOCUS;
  WM_QUIT      = LM_QUIT;


  // PEEKMESSAGE stuff
  PM_Noremove = 0;
  PM_Remove = 1;
  PM_NOYIELD = 2;
{$ENDIF}
implementation

end.
