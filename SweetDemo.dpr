
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

var
  handle : integer;

function OnOkButtonClick(const evt : TSweet.RMessage) : integer;
var
  msg : TSweet.RMessage;

begin
  msg.Id := TSweet.Message_Id_Close;
  TSweet.PostMessage(msg);

  result := 0;
end;

begin
  // If one need multitasking, it should start the other threads here !

  handle := TSweet.LoadWindow(TPath.Combine(ParamStr(0), 'HelloWorld.json'));
  TSweet.BindEvent(handle, 1, TSweet.Event_Id_Click, OnOkButtonClick);
  TSweet.RunApplication(handle); // As usual the main thread should run the entire UI
end.

