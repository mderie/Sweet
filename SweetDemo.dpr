
program SweetDemo;

// No idea if it is that easy to jump later to a graphic mode and pump the window message queue...
{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Sharemem,
  System.SysUtils,
  System.IOUtils,
  SweetWrapper in 'SweetWrapper.pas',
  Sweet.Common in 'Sweet.Common.pas';

const
  HARD_CODED_PATH : PAnsiChar = 'c:\laboratory\Sweet\Win32\Debug\HelloWorld.json';

var
  handle : integer;
  fullFilename : string;
  s : PAnsiChar;

function OnOkButtonClick(const evt : TSweet.RMessage) : integer;
var
  msg : TSweet.RMessage;

begin
  msg.Id := TSweet.Message_Id_Close;
  TSweet.PostMessage(msg);

  result := 0;
end;

begin
  writeln('29 + 2 = ', IntToStr(SweetSimpleAddition(29, 2)));
  //writeln('Press ENTER to continue or CTRL-C to stop...');
  //var dummy : string; readln(dummy);
  // If one need multitasking, it should start the other threads here !

  // KO
  //handle := TSweet.LoadWindow(TPath.Combine(ParamStr(0), 'HelloWorld.json'));

  // KO
  //fullFilename := TPath.Combine(ParamStr(0), 'HelloWorld.json');
  //StrPCopy(s, AnsiString(fullFilename));
  //handle := SweetLoadWindow(s);

  // OK
  handle := SweetLoadWindow(HARD_CODED_PATH);

  TSweet.BindEvent(handle, 1, TSweet.Event_Id_Click, OnOkButtonClick);
  TSweet.RunApplication(handle); // As usual the main thread should run the entire UI
end.

