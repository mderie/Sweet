
//
// The Delphi wrapper is particular since both the program and the library are written in Delphi !
// Hence the SweetCommon unit :)
//

unit SweetWrapper;

interface

uses
  Sweet.Common;

type
  TSweetHelper = class helper for TSweet
    class function LoadWindow(const fullFilename : string) : integer;
    class function RunApplication(const windowHandle : integer) : integer;
    class function BindEvent(const windowHandle : integer; const widgetHandle : integer; const eventId : integer; const eventHandler : TSweet.TEventHandler) : integer;
    class function PostMessage(const msg : TSweet.RMessage) : integer;
  end;

function SweetSimpleAddition(const A : integer; const B : integer) : integer; stdcall; external 'Sweet.dll';
function SweetLoadWindow(const fullFilename : PAnsiChar) : integer; stdcall; external 'Sweet.dll';

implementation

uses
  System.SysUtils;

// Implicit linking, not need to call LoadLibrary https://stackoverflow.com/questions/10405991/calling-functions-from-a-c-dll-in-delphi
//function SweetLoadWindow(const fullFilename : PAnsiChar) : integer; stdcall; external 'Sweet.dll';
function SweetRunApplication(const windowHandle : integer) : integer; stdcall; external 'Sweet.dll';
function SweetBindEvent(const windowHandle : integer; const widgetHandle : integer; const eventId : integer; const eventHandler : TSweet.TEventHandler) : integer; stdcall; external 'Sweet.dll';
function SweetPostMessage(const msg : TSweet.RMessage) : integer; stdcall; external 'Sweet.dll';

class function TSweetHelper.LoadWindow(const fullFilename : string) : integer;
var
  s : PAnsiChar;
  //s : rawByteString; // Or AnsiString (since it is alias...

begin
  try
    // Compile but wrong ?
    //StrPCopy(s, AnsiString(fullFilename));
    s := PAnsiChar(AnsiString(fullFilename)); // Ok but WTF ?
    result := SweetLoadWindow(s);
    //result := SweetLoadWindow(UTF8Encode(fullFilename));
    if (result = -1) then begin
      raise Exception.Create('Unable to load window !');
    end;
  except
    on e : Exception do begin
      // Anything ?
      raise; // Optional
    end;
  end;
end;

class function TSweetHelper.RunApplication(const windowHandle : integer) : integer;
begin
  try
    result := SweetRunApplication(windowHandle);
    if (result = -1) then begin
      raise Exception.Create('Unable to run application !');
    end;
  except
    on e : Exception do begin
      raise;
    end;
  end;
end;

class function TSweetHelper.BindEvent(const windowHandle : integer; const widgetHandle : integer; const eventId : integer; const eventHandler : TSweet.TEventHandler) : integer;
begin
  try
    result := SweetBindEvent(windowHandle, widgetHandle, eventId, eventHandler);
    if (result = -1) then begin
      raise Exception.Create('Unable to bind event !');
    end;
  except
    on e : Exception do begin
      raise;
    end;
  end;
end;

class function TSweetHelper.PostMessage(const msg : TSweet.RMessage) : integer;
begin
  try
    result := SweetPostMessage(msg);
    if (result = -1) then begin
      raise Exception.Create('Unable to post message !');
    end;
  except
    on e : Exception do begin
      raise;
    end;
  end;
end;

end.

