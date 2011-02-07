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
		self.isAccelerometerEnabled = YES;
		player = [CCSprite spriteWithFile:@"alien.png"];
		[self addChild:player z:0 tag:1];
		CGSize screenSize = [[CCDirector sharedDirector] winSize];
		float imageHeight = [player texture].contentSize.height;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
	}
	[self scheduleUpdate];
	return self;
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float deceleration = 0.4f;
	float sensitivity = 6.0f;
	float maxVelocity = 100;
	playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
	if (playerVelocity.x > maxVelocity)
	{
		playerVelocity.x = maxVelocity;
	}
	else if (playerVelocity.x < - maxVelocity)
	{
		playerVelocity.x = - maxVelocity;
	}
}

-(void) update:(ccTime)delta
{
	CGPoint pos = player.position;
	pos.x += playerVelocity.x;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	float imageWidthHalved = [player texture].contentSize.width * 0.5f;
	float leftBorderLimit = imageWidthHalved;
	float rightBorderLimit = screenSize.width - imageWidthHalved;
	if (pos.x < leftBorderLimit){
		pos.x = leftBorderLimit;
		playerVelocity = CGPointZero;		
	}
	else if (pos.x > rightBorderLimit) {
		pos.x = rightBorderLimit;
		playerVelocity = CGPointZero;
	}
	player.position = pos;
}
-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd),self);
	[super dealloc];
}
@end
