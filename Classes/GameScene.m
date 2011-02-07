//
//  GameScene.m
//  DoodleDrop
//
//  Created by fernando martinez-gil gutierrez de la Cámara on 06/02/11.
//  Copyright 2011 None. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	CCLayer *layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}
-(id) init 
{
	if ((self = [super init])) 
	{
		CCLOG(@"%@: %@", NSStringFromSelector(_cmd),self);
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd),self);
	[super dealloc];
}
@end
