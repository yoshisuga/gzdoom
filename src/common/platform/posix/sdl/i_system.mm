#include <CoreFoundation/CoreFoundation.h>
#include "SDL.h"

#import "TargetConditionals.h"
#import <os/log.h>

void Mac_I_FatalError(const char* errortext)
{
	// Close window or exit fullscreen and release mouse capture
	SDL_Quit();

	const CFStringRef errorString = CFStringCreateWithCStringNoCopy( kCFAllocatorDefault, 
		errortext, kCFStringEncodingASCII, kCFAllocatorNull );
	if ( NULL != errorString )
	{
		CFOptionFlags dummy;

#if TARGET_OS_IPHONE
        const char *s = CFStringGetCStringPtr(errorString, kCFStringEncodingUTF8);
        printf("Fatal error: %s",s);
    os_log(OS_LOG_DEFAULT, "GenZD Fatal error: %{public}s",s);
#else
		CFUserNotificationDisplayAlert( 0, kCFUserNotificationStopAlertLevel, NULL, NULL, NULL, 
			CFSTR( "Fatal Error" ), errorString, CFSTR( "Exit" ), NULL, NULL, &dummy );
		CFRelease( errorString );
#endif
	}
}
