#include <CoreFoundation/CoreFoundation.h>
#include "SDL.h"

#import "TargetConditionals.h"

void Mac_I_FatalError(const char* errortext)
{
	// Close window or exit fullscreen and release mouse capture
	SDL_Quit();
	
	const CFStringRef errorString = CFStringCreateWithCStringNoCopy( kCFAllocatorDefault, 
		errortext, kCFStringEncodingASCII, kCFAllocatorNull );
	if ( NULL != errorString )
	{
		CFOptionFlags dummy;

#if TARGET_OS_IOS
        const char *s = CFStringGetCStringPtr(errorString, kCFStringEncodingUTF8);
        printf("Fatal error: %s",s);
#else
		CFUserNotificationDisplayAlert( 0, kCFUserNotificationStopAlertLevel, NULL, NULL, NULL, 
			CFSTR( "Fatal Error" ), errorString, CFSTR( "Exit" ), NULL, NULL, &dummy );
		CFRelease( errorString );
#endif
	}
}
