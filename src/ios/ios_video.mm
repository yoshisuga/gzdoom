//
//  ios_video.m,
//  zdoom_native
//
//  Created by Yoshi Sugawara on 11/14/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VK_USE_PLATFORM_IOS_MVK
#include "volk/volk.h"

#include "v_video.h"
#include "bitmap.h"
#include "c_dispatch.h"
#include "hardware.h"
#include "i_system.h"
#include "m_argv.h"
#include "m_png.h"
#include "v_text.h"
#include "version.h"
#include "printf.h"
#include "gl_framebuffer.h"
#include "gles_framebuffer.h"

#include "vulkan/system/vk_framebuffer.h"

#include "ios-glue.h"
#import "IOSUtils.h"
#import "zdoom_native-Swift.h"

EXTERN_CVAR (Int, vid_defwidth)
EXTERN_CVAR (Int, vid_defheight)

@interface VulkanView: UIView
@end

@implementation VulkanView

+(Class) layerClass { return [CAMetalLayer class]; }

@end

class IOSVideo : public IVideo
{
public:
    IOSVideo()
    {
    }

    ~IOSVideo()
    {
        delete m_vulkanDevice;
    }
    
    virtual DFrameBuffer* CreateFrameBuffer() override
    {
        SystemBaseFrameBuffer *fb = nullptr;
        
        int width, height;
        ios_get_screen_width_height(&width, &height);
        
//        VulkanView *view = [[VulkanView alloc] initWithFrame:CGRectMake(0, 0, CGFloat(width), CGFloat(height))];
//        vulkanView = [[IOSUtils shared] getView];
//        assert(vulkanView != nil);
        setenv("MVK_CONFIG_LOG_LEVEL", "1", 0);
        // The following settings improve performance like suggested at
        // https://github.com/KhronosGroup/MoltenVK/issues/581#issuecomment-487293665
        setenv("MVK_CONFIG_SYNCHRONOUS_QUEUE_SUBMITS", "0", 0);
        setenv("MVK_CONFIG_PRESENT_WITH_COMMAND_BUFFER", "0", 0);
        
        m_vulkanDevice = new VulkanDevice();
        fb = new VulkanFrameBuffer(nullptr, true, m_vulkanDevice);
        // need to do anything else..?
        return fb;
    }
    
//    static GZDoomView* GetView()
//    {
//        return vulkanView;
//    }
private:
    VulkanDevice *m_vulkanDevice = nullptr;
//    static VulkanView *vulkanView;
//    static GZDoomView *vulkanView;
};

//GZDoomView* IOSVideo::vulkanView;
//VulkanView* IOSVideo::vulkanView;

static SystemBaseFrameBuffer* frameBuffer;

SystemBaseFrameBuffer::SystemBaseFrameBuffer (void *, bool fullscreen)
: DFrameBuffer (vid_defwidth, vid_defheight)
{
    NSLog(@"Create SystemBaseFrameBuffer!");
    // this seems like where the video is initialized...? or the view is attached? need to figure out the order..
}

int SystemBaseFrameBuffer::GetClientWidth()
{
    int width, height;
    ios_get_screen_width_height(&width, &height);
    return width;
}

int SystemBaseFrameBuffer::GetClientHeight()
{
    int width, height;
    ios_get_screen_width_height(&width, &height);
    return height;
}

bool SystemBaseFrameBuffer::IsFullscreen ()
{
    return true;
}

void SystemBaseFrameBuffer::ToggleFullscreen(bool yes)
{
}

void SystemBaseFrameBuffer::SetWindowSize(int w, int h)
{
    NSLog(@"SystemBaseFrameBuffer::SetWindowSize SetWindowSize: %i x %i", w, h);
    // don't think i need to do anything here...?
}

// no-op-ing these GL ones cuz its MoltenVK only for iOS!

SystemGLFrameBuffer::SystemGLFrameBuffer(void *hMonitor, bool fullscreen)
: SystemBaseFrameBuffer(hMonitor, fullscreen)
{
}

SystemGLFrameBuffer::~SystemGLFrameBuffer ()
{
}

int SystemGLFrameBuffer::GetClientWidth()
{
    return 0;
}

int SystemGLFrameBuffer::GetClientHeight()
{
    return 0;
}

void SystemGLFrameBuffer::SetVSync( bool vsync )
{
}

void SystemGLFrameBuffer::SwapBuffers()
{
}

// ---------------------------------------------------------------------------


IVideo* Video;


// ---------------------------------------------------------------------------

void I_ShutdownGraphics()
{
    if (NULL != screen)
    {
        delete screen;
        screen = NULL;
    }

    delete Video;
    Video = NULL;
}

void I_InitGraphics()
{
    Video = new IOSVideo;
}

bool I_SetCursor(FGameTexture *cursorpic)
{
    // umm do i need to do anything for iOS?
    return true;
}

void I_SetWindowTitle(const char* title)
{
}

void I_GetVulkanDrawableSize(int *width, int *height)
{
//    GZDoomView *view = [[IOSUtils shared] getView];
//    if (!view) {
        ios_get_screen_width_height(width, height);
//        return;
//    }
//    CAMetalLayer *layer = (CAMetalLayer*)view.layer;
//    *width = layer.drawableSize.width;
//    *height = layer.drawableSize.height;
}

bool I_GetVulkanPlatformExtensions(unsigned int *count, const char **names)
{
    static std::vector<const char*> extensions;

    if (extensions.empty())
    {
        uint32_t extensionPropertyCount = 0;
        vkEnumerateInstanceExtensionProperties(nullptr, &extensionPropertyCount, nullptr);

        std::vector<VkExtensionProperties> extensionProperties(extensionPropertyCount);
        vkEnumerateInstanceExtensionProperties(nullptr, &extensionPropertyCount, extensionProperties.data());

        static const char* const EXTENSION_NAMES[] =
        {
            VK_KHR_SURFACE_EXTENSION_NAME,        // KHR_surface, required
            VK_MVK_IOS_SURFACE_EXTENSION_NAME
//            VK_EXT_METAL_SURFACE_EXTENSION_NAME,  // EXT_metal_surface, optional, preferred
//            VK_MVK_MACOS_SURFACE_EXTENSION_NAME,  // MVK_macos_surface, optional, deprecated
        };

        for (const VkExtensionProperties &currentProperties : extensionProperties)
        {
            for (const char *const extensionName : EXTENSION_NAMES)
            {
                if (strcmp(currentProperties.extensionName, extensionName) == 0)
                {
                    extensions.push_back(extensionName);
                }
            }
        }
    }

    static const unsigned int extensionCount = static_cast<unsigned int>(extensions.size());
    assert(extensionCount >= 2); // KHR_surface + at least one of the platform surface extentions

    if (count == nullptr && names == nullptr)
    {
        return false;
    }
    else if (names == nullptr)
    {
        *count = extensionCount;
        return true;
    }
    else
    {
        const bool result = *count >= extensionCount;
        *count = std::min(*count, extensionCount);

        for (unsigned int i = 0; i < *count; ++i)
        {
            names[i] = extensions[i];
        }

        return result;
    }
}

bool I_CreateVulkanSurface(VkInstance instance, VkSurfaceKHR *surface)
{
    GZDoomView *view = [[IOSUtils shared] getView];
    CALayer *layer = view.layer;
    // Set magnification filter for swapchain image when it's copied to a physical display surface
    // This is needed for gfx-portability because MoltenVK uses preferred nearest sampling by default
    const char *const magFilterEnv = getenv("MVK_CONFIG_SWAPCHAIN_MAG_FILTER_USE_NEAREST");
    const bool useNearestFilter = magFilterEnv == nullptr || strtol(magFilterEnv, nullptr, 0) != 0;
    layer.magnificationFilter = useNearestFilter ? kCAFilterNearest : kCAFilterLinear;
    
    VkIOSSurfaceCreateInfoMVK createInfo;
    createInfo.sType = VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK;
    createInfo.pNext = nullptr;
    createInfo.flags = 0;
    createInfo.pView = (__bridge void*)view;
    const VkResult result = vkCreateIOSSurfaceMVK(instance, &createInfo, NULL, surface);
    return result == VK_SUCCESS;
}

void I_PolyPresentInit()
{
}

uint8_t *I_PolyPresentLock(int w, int h, bool vsync, int &pitch)
{
    return 0;
}

void I_PolyPresentUnlock(int x, int y, int w, int h)
{
}

void I_PolyPresentDeinit()
{
}
