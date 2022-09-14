
library Sweet;

uses
  System.Sharemem,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  WinAPI.Windows,
  quickLogger in 'quickLogger.pas',
  Sweet.Common in 'Sweet.Common.pas',
  Sweet.Widget in 'Sweet.Widget.pas';

{$R *.res}

type
(*
  TDummy = class
    class procedure ArtificialShutDown(Sender : TObject);
  end;
*)

  TFakeTimerThread = class(TThread)
  public
    procedure Execute; override;
  end;

var
  //endOfTimeThread : TgtTimerThread;
  //endOfTime : TgtTimer;
  eternalLoop : boolean;
  lock : TObject;

  //windows : TArray<...>

function LoadWindow(const fullFilename : PAnsiChar) : integer; stdcall;
var
  s : AnsiString;
  //json : TJSONValue;

begin
  {$ifdef DEBUG} logEnter('LoadWindow'); try {$endif DEBUG}

  s := StrPas(fullFilename);
  //json := TJSONObject.ParseJSONValue(pchar(TFile.ReadAllText(string(s))), 0);
  logDebug(Format('fullFilename = %s succesfuly loaded', [string(fullFilename)]));

  result := 0;

  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
end;

// Blocking call ! Except that for the sake of the demo we will use a timer do shutdown ourself
function RunApplication(const handle : integer) : integer; stdcall;
begin
  {$ifdef DEBUG} logEnter('RunApplication'); try {$endif DEBUG}

  // Save current running mode

  // Jump to graphic mode

  // Render all visible windows

  // Activate the main one

  while (true) do begin
    TMonitor.Enter(lock);
    try
      if (not eternalLoop) then begin
        break;
      end;
    finally
      TMonitor.Exit(lock);
    end;

    // Process messages
  end;

  // Restore running mode

  result := 0;

  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
end;

function BindEvent(const windowHandle : integer; const widgetHandle : integer; const eventId : integer; const eventHandler : TSweet.TEventHandler) : integer; stdcall;
begin
  {$ifdef DEBUG} logEnter('BindEvent'); try {$endif DEBUG}

  //TODO: ...

  result := 0;

  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
end;

function PostMessage(const msg : TSweet.RMessage) : integer; stdcall;
begin
  {$ifdef DEBUG} logEnter('PostMessage'); try {$endif DEBUG}

  //TODO: ...

  result := 0;

  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
end;

function SimpleAddition(const A : integer; const B : integer) : integer; stdcall;
begin
  //logParameters('0', '', '', '1');
  {$ifdef DEBUG} logEnter('SimpleAddition'); try {$endif DEBUG}
  result := A + B;
  writeln(Format('result = %s', [IntToStr(result)]));
  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
  //logParameters('6', '', '', '1');
end;

exports
  SimpleAddition name 'SweetSimpleAddition',
  LoadWindow name 'SweetLoadWindow',
  RunApplication name 'SweetRunApplication',
  BindEvent name 'SweetBindEvent',
  PostMessage name 'SweetPostMessage';

(*
class procedure TDummy.ArtificialShutDown(Sender : TObject);
begin
  {$ifdef DEBUG} logEnter('ArtificialShutDown'); try {$endif DEBUG}
  endOfTime.Enabled := false;
  eternalLoop := false;
  {$ifdef DEBUG} finally logLeave(); end; {$endif DEBUG}
end;

procedure prelude();
begin
  logParameters('6', '', '', '1');
  {$ifdef DEBUG} logEnter('prelude'); {$endif DEBUG}
  eternalLoop := true;

  endOfTime := nil;
  endOfTimeThread := nil;

  endOfTime := TgtTimer.Create(nil);
  endOfTimeThread := TgtTimerThread.Create(EndOfTime);
  endOfTime.Interval := 3000;
  endOfTime.OnTimer := TDummy.ArtificialShutDown;
  endOfTime.Enabled := true;

  {$ifdef DEBUG} logLeave(); {$endif DEBUG}
end;

procedure postlude();
begin
  {$ifdef DEBUG} logEnter('postlude'); {$endif DEBUG}
  endOfTime.Free();
  endOfTimeThread.Free();
  {$ifdef DEBUG} logLeave(); {$endif DEBUG}
end;
*)

procedure TFakeTimerThread.Execute();
begin
  {$ifdef DEBUG} logEnter('TFakeTimerThread.Execute'); {$endif DEBUG}
  Sleep(3000);

  TMonitor.Enter(lock);
  try
    eternalLoop := false;
  finally
    TMonitor.Exit(lock);
  end;

  FreeOnTerminate := true; // Lost in space anyway :( But why ?
  {$ifdef DEBUG} logLeave(); {$endif DEBUG}
end;

procedure prelude();
begin
  logParameters('0', '', '', '1');
  {$ifdef DEBUG} logEnter('prelude'); {$endif DEBUG}
  lock := TObject.create();
  eternalLoop := true;
  TFakeTimerThread.Create(false);

  {$ifdef DEBUG} logLeave(); {$endif DEBUG}
  //logParameters('6', '', '', '1'); // Don't log anymore ! Crazy errors when dealing with file IO... Due to dll ?
end;

procedure postlude();
begin
  {$ifdef DEBUG} logEnter('postlude'); {$endif DEBUG}
  lock.Free();
  {$ifdef DEBUG} logLeave(); {$endif DEBUG}
end;

// Adapted from https://stackoverflow.com/questions/15484752/finalization-section-not-being-run-in-a-dll
procedure DLLMain(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH: prelude();
    DLL_PROCESS_DETACH: postlude();
  end;
end;

begin
  DLLProc := @DLLMain;
  DLLMain(DLL_PROCESS_ATTACH);
end.

