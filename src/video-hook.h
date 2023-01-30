//
//  video-hook.h
//  GZDoom
//
//  Created by Yoshi Sugawara on 10/23/21.
//

#ifndef video_hook_h
#define video_hook_h
#include "SDL_syswm.h"

void SDLWindowAfterCreate(SDL_Window *sdlWindow);
void SDLWindowAfterSurfaceCreate(SDL_Window *sdlWindow);

#endif /* video_hook_h */
