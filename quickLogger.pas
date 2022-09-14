
unit quickLogger;

{$I+,O-}

interface

uses
  System.SysUtils;

// NB :
// - All this could have been put into a class with static methods...
// - All procedures are exception free !

procedure logVerbose(const value : string);
procedure logDebug(const value : string);
procedure logInfo(const value : string);
procedure logWarning(const value : string);
procedure logError(const value : string);
procedure logException(const value : string; const e : Exception);

// Since all parameters are optional, one can just pass an empty string to keep the existing value as is
// Level legal values are between '0' (verbose) and '6' (none) and for splitByDay it is from '0' to '1'
// Parameters applies to all threads !
procedure logParameters(const level, splitByDay, folder, echoToConsole : string);

//TODO: Even with the reflection, deducing the method name seems impossible...Delphi lacks of __FUNCTION__ macro !
// https://stackoverflow.com/questions/2817699/how-to-get-the-name-of-the-current-procedure-function-in-delphi-as-a-string
procedure logEnter(const location : string);
procedure logLeave();

implementation

uses
  Winapi.Windows, System.DateUtils, System.generics.collections;

const
  BASE_FILE_NAME = 'quickLog';
  BASE_FILE_EXTENTION = '.txt';
  TIME_FORMAT = 'HH:NN:SS.ZZZ';
  DATE_FORMAT = 'YYYY/MM/DD';

type
  TLogLevel = (llVerbose, llDebug, llInfo, llWarning, llError, llException, llNone);
  TStackOfString = TStack<string>; // Hold the code location...
  TDictionaryOfThread = TDictionary<cardinal, TStackOfString>; // ...Per thread !

var
  logPadlock, colPadlock : TObject; // We should avoid having two locks (in order to avoid any deadlock situations)
  callStacks : TDictionaryOfThread;
  folder, filename, dtFormat : string;
  level : TLogLevel;
  lastUsedDay : TDateTime;
  splitByDay, echoToConsole : boolean;

function getThreadCallStack() : TStackOfString;
var
  tid : cardinal;

begin
  TMonitor.Enter(colPadlock);
  try
    tid := getCurrentThreadId();
    if (not callStacks.ContainsKey(tid)) then begin
      callStacks.Add(tid, TStack<string>.create());
    end;
    result := callStacks[tid];
  finally
    TMonitor.Exit(colPadlock);
  end;
end;

// We could put some variables (all ?) into a threadvar section and then avoid the padlock :)

procedure checkEOD(const dt : TDateTime);
begin
  if (not splitByDay) then begin
    exit;
  end;

  if ((lastUsedDay = 0.0) or (not samedate(lastUsedDay, dt))) then begin
    filename := BASE_FILE_NAME + '_' + formatDateTime('YYYYMMDD', dt) + BASE_FILE_EXTENTION;
  end;
  lastUsedDay := dt;
end;

// https://forum.lazarus.freepascal.org/index.php?topic=42155.0
function SecureFileExists(const fullFilename : string) : boolean;
var
  SearchRec : TSearchRec;

begin
  // result := (FindFirst(fullFilename, faAnyFile, SearchRec) = 0); // Issue here !!!
  result := true;
end;

//TODO: Do we need a real logger framework ? In the meantime, this one is stateless on purpose :-)
// Known missing feature : rolling file appender (see Log4x) with archiving and deleting policies...
// ==> The plan is to use LogRotate as external tool : https://github.com/plecos/logrotatewin.git
procedure quickLog(const header : char; const value : string);
var
  f : TextFile;
  dt : TDateTime;
  fullFilename, location, content : string;
  callStack : TStackOfString;

begin
  try
    TMonitor.Enter(logPadlock);
    try
      dt := now();
      checkEOD(dt);
      fullFilename := folder + filename;
      assignFile(f, fullFilename);

      if (SecureFileExists(fullFilename)) then begin
        append(f);
      end
      else begin
        rewrite(f);
      end;

      // Yet another issue : the true part is evaluated even though the test part is false ! ==> Compile time vs runtime evaluation
      //location := StrUtils.IfThen((callStack.Count > 0), StringOfChar(' ', callStack.Count) + callStack.Peek() + ' ==> ', '') ;
      callStack := getThreadCallStack();
      if (callStack.Count > 0) then begin
        location := StringOfChar(' ', callStack.Count) + callStack.Peek() + ' ==> '; // Or use (x) ?
      end
      else begin
        location := '';
      end;
      content := format('%s %s (PID=%s/TID=%s) %s%s', [header, formatDateTime(dtFormat, dt), IntToHex(getCurrentProcessId(), 1), IntToHex(getCurrentThreadId(), 1), location, value]);
      writeln(f, content);
      flush(f);
      closeFile(f);

      if (echoToConsole) then begin
        writeln(content);
      end;

    finally
      TMonitor.Exit(logPadlock);
    end;
  except
    // Nothing to do...
  end;
end;

procedure logFilter(const value : string; const logLevel : TLogLevel);
begin
  if (level > logLevel) then begin
    exit;
  end;

  quickLog(chr(integer(logLevel) + ord('0')), value);
end;

procedure logVerbose(const value : string);
begin
  logFilter(value, llVerbose);
end;

procedure logDebug(const value : string);
begin
  logFilter(value, llDebug);
end;

procedure logInfo(const value : string);
begin
  logFilter(value, llInfo);
end;

procedure logWarning(const value : string);
begin
  logFilter(value, llWarning);
end;

procedure logError(const value : string);
begin
  logFilter(value, llError);
end;

procedure logException(const value : string; const e : Exception);
begin
  logFilter(format('%s e.ClassName = %s & e.Message = %s', [value, e.ClassName, e.Message]), llException);
end;

procedure setLevel(const value : string);
begin
  if ((length(value) = 1) and (value >= '0') and (value <= '6')) then begin
    level := TLogLevel(StrToInt(value));
  end;
end;

procedure setSplitByDay(const value : string);
begin
  if ((value <> '1') and (value <> '0')) then begin
    exit;
  end;

  splitByDay := (value = '1');
  if (splitByDay) then begin
    dtFormat := TIME_FORMAT;
  end
  else begin
    dtFormat := DATE_FORMAT + ' ' + TIME_FORMAT;
    filename := BASE_FILE_NAME + BASE_FILE_EXTENTION;
  end;
end;

procedure setFolder(const value : string);
begin
  if ((value = folder) or (value = '')) then begin
    exit;
  end;

  try
    // Try to create all folders, if needed, in one shot !
    if (not forceDirectories(value)) then begin
      exit;
    end;

    folder := IncludeTrailingPathDelimiter(value);
  except
    // Nothing to do ? Nope : we keep the default value !
  end;
end;

procedure setEchoToConsole(const value : string);
begin
  if (value = '') then begin
    exit;
  end;

  echoToConsole := (value = '1');
end;

procedure logParameters(const level, splitByDay, folder, echoToConsole : string);
begin
  try
    TMonitor.Enter(logPadlock);
    try
      setLevel(level);
      setSplitByDay(splitByDay);
      setFolder(folder);
      setEchoToConsole(echoToConsole);
    finally
      TMonitor.Exit(logPadlock);
    end;
  except
    // Nothing to do...
  end;
end;

procedure logEnter(const location : string);
begin
  try
    logVerbose(format('Entering %s', [location]));
    getThreadCallStack().Push(location);
  except
    // Nothing to do...
  end;
end;

procedure logLeave();
var
  callStack : TStackOfString;

begin
  try
    callStack := getThreadCallStack();
    if (callStack.Count > 0) then begin
      logVerbose(format('Leaving %s', [callStack.Pop()]));
    end;
  except
    // Nothing to do...
  end;
end;

procedure prelude();
begin
  callStacks := nil;
  colPadlock := nil;
  logPadlock := nil;

  callStacks := TDictionaryOfThread.create(); // Using a type here avoid some typping :)
  colPadlock := TObject.create();
  logPadlock := TObject.create();
  lastUsedDay := 0.0;
  splitByDay := false;
  echoToConsole := false;
  level := llDebug;
  filename := BASE_FILE_NAME + BASE_FILE_EXTENTION;
  dtFormat := DATE_FORMAT + ' ' + TIME_FORMAT;
  // Care : we suppose here that we are running code from an exe file !-)
  folder := IncludeTrailingPathDelimiter(ExtractFilePath(Paramstr(0)));
end;

procedure postlude();
var
  callStack : TStackOfString;

begin
  logPadlock.Free();
  colPadlock.Free();
  if (assigned(callStacks)) then begin
    for callStack in callStacks.Values do begin
      callStack.free();
    end;
    callStacks.Free();
  end;
end;

initialization
  prelude();

finalization
  postlude();

end.

