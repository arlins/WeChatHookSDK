
#import "UIApplication+TopViewController.h"

@implementation UIApplication(TopViewController)

- (UIViewController *)currentTopViewController
{
    UIWindow *keyWindow = self.keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    
    return vc;
}

@end
