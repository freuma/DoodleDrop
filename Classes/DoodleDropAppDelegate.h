//
//  DoodleDropAppDelegate.h
//  DoodleDrop
//
//  Created by fernando martinez-gil gutierrez de la Cámara on 06/02/11.
//  Copyright None 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface DoodleDropAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
