
#ifndef SWEET_HPP_WRAPPER
#define SWEET_HPP_WRAPPER

namespace sweet
{
	
#include "sweet.h"	

class Sweet
{	
public:
static int LoadWindow(const pchar fullFilename) { return SweetLoadWindow(fullFilename); }
static bool RunApplication(const int windowHandle) { return (SweetRunApplication(windowHandle) != -1); }
static bool BindEvent(const int windowHandle; const int widgetHandle; const int eventId; const EventHandler eventHandler) { return (SweetBindEvent(windowHandle, widgetHandle, eventId, eventHandler) != -1); }
static bool PostMessage(const msg : SMessage) { return (SweetPostMessage(msg) != -1); };
};

} // namespace sweet

#endif // SWEET_HPP_WRAPPER
