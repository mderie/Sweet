
#ifndef SWEET_H_WRAPPER
#define SWEET_H_WRAPPER

struct SMessage
{
  int Id;
  int Sender;
  int Key;
  int Value;
}

const Message_Id_Close = 1;
// const Message_Id_...

const Event_Id_Click = 1;
// const Event_Id_...

typedef int EventHandler(const SMessage);

external "C" int __stdcall SweetLoadWindow(const char *fullFilename);
external "C" int __stdcall SweetRunApplication(const int windowHandle);
external "C" int __stdcall BindEvent(const int windowHandle; const int widgetHandle; const int eventId; const EventHandler eventHandler);
external "C" int __stdcall PostMessage(const SMessage msg);

#endif // SWEET_H_WRAPPER
