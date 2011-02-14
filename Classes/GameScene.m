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
		totalTime = 0;
		score = 0;
		player.position = CGPointMake(screenSize.width / 2, imageHeight / 2);
		scoreLabel = [CCLabelBMFont  labelWithString:@"0" fntFile:@"fuenteNumeracionDoodle.fnt"];
		scoreLabel.position = CGPointMake(screenSize.width/2, screenSize.height);
		scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"blues.mp3" loop:YES];
		[self addChild:scoreLabel z:-1 tag:10];
		[self scheduleUpdate];
		[self initSpiders];
	}
	
	return self;
}
-(void) initSpiders
{
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"spider.png"];
	float	imageWidth = [tempSpider texture].contentSize.width;
	int numSpiders = screenSize.width /imageWidth;
	spiders = [[CCArray alloc]initWithCapacity:numSpiders];
	spiderMoveDuration = 6.0;
	numSpidersMoved = 0;
	for (int i = 0; i < numSpiders; i++)
	{
		CCSprite* spider = [CCSprite spriteWithFile:@"spider.png"];
		[self addChild:spider z:0 tag:2];
		[spiders addObject:spider];
		NSLog(@"Añade una araña");
	}
	[self resetSpiders];
}

-(void) resetSpiders
{
	NSLog(@"resetea una araña");
	CGSize screenSize = [[CCDirector sharedDirector]winSize];
	CCSprite* tempSpider = [spiders lastObject];
	CGSize size = [tempSpider texture].contentSize;
	int numSpiders = [spiders count];
	for (int i = 0; i < numSpiders; i++)
	{
		CCSprite* spider = [spiders objectAtIndex:i];
		spider.position = CGPointMake(size.width * i + size.width * 0.5f,screenSize.height + size.height);
		[spider stopAllActions];
	}
	totalTime = 0;
	
	[self unschedule:@selector(spidersUpdate:)];
	[self schedule:@selector(spidersUpdate:) interval:0.7f];
	
}

-(void) runSpiderMoveSequence:(CCSprite*)spider
{
	NSLog(@"Mueve una araña");
	numSpidersMoved++;
	if (numSpidersMoved % 8 == 0 && spiderMoveDuration > 3.0f)
	{
		spiderMoveDuration -= 0.1f;
	}
	CGPoint belowScreenPosition = CGPointMake(spider.position.x, -[spider texture].contentSize.height);
	CCMoveTo* move = [CCMoveTo actionWithDuration:spiderMoveDuration position:belowScreenPosition];
	CCCallFuncN* call = [CCCallFuncN actionWithTarget:self selector:@selector(spiderBelowScreen:)];
	CCSequence* sequence = [CCSequence actions: move, call , nil];
	[spider runAction:sequence];
}

-(void) spidersUpdate:(ccTime)delta
{
	NSLog(@"Araña updateada");
	for(int i = 0;i< 10; i++)
	{
		int randomSpiderIndex = CCRANDOM_0_1() *[spiders count];
		CCSprite* spider = [spiders objectAtIndex:randomSpiderIndex];
		if ([spider numberOfRunningActions] == 0){
			[self runSpiderMoveSequence: spider];
			break;
		}
	}
}

-(void) spiderBelowScreen:(id)sender
{
	NSLog(@"Araña bajo pantalla");
	NSAssert([sender isKindOfClass:[CCSprite class]],@"sender is not a CCSprite");
	CCSprite* spider = (CCSprite *)sender;
	CGPoint pos = spider.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.y = screenSize.height + [spider texture].contentSize.height;
	spider.position = pos;
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
	totalTime = totalTime + delta;
	//NSLog(@"timeAux: %i",timeAux);
	int currentTime = (int)totalTime;
//	[scoreLabel setString:[NSString stringWithFormat:@"%i", timeAux]];
	if ((int)score < (int)currentTime)
	{
		score = (int)currentTime;
		[scoreLabel setString:[NSString stringWithFormat:@"%i", score]];
	}
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
	[self checkForCollision];
}

-(void) checkForCollision{
	float playerImageSize = [player texture].contentSize.width;
	float spiderImageSize = [[spiders lastObject] texture].contentSize.width;
	float playerCollisionRadius = playerImageSize * 0.4f;
	float spiderCollisionRadius = spiderImageSize * 0.4f;
	float maxCollisionDistance = playerCollisionRadius + spiderCollisionRadius;
	int numSpiders = [spiders count];
	
	for (int i = 0;i < numSpiders;i++)
	{
		CCSprite* spider = [spiders objectAtIndex:i];
		if ([spider numberOfRunningActions] == 0)
		{
			continue;
		}
		float actualDistance = ccpDistance(player.position, spider.position);
		if (actualDistance < maxCollisionDistance)
		{
			[[SimpleAudioEngine sharedEngine] playEffect:@"alien-sfx.caf"];
			[self showGameOver];
		}
	}
}
-(void) runSpiderWiggleSequence:(CCSprite*)spider
{
	// Do something icky with the spiders ...
	CCScaleTo* scaleUp = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:1.05f];
	CCEaseBackInOut* easeUp = [CCEaseBackInOut actionWithAction:scaleUp];
	CCScaleTo* scaleDown = [CCScaleTo actionWithDuration:CCRANDOM_0_1() * 2 + 1 scale:0.95f];
	CCEaseBackInOut* easeDown = [CCEaseBackInOut actionWithAction:scaleDown];
	CCSequence* scaleSequence = [CCSequence actions:easeUp, easeDown, nil];
	CCRepeatForever* repeatScale = [CCRepeatForever actionWithAction:scaleSequence];
	[spider runAction:repeatScale];
}

#pragma mark Reset Game
// The game is played only using the accelerometer. The screen may go dark while playing because the player
// won't touch the screen. This method allows the screensaver to be disabled during gameplay.
-(void) setScreenSaverEnabled:(bool)enabled
{
	UIApplication *thisApp = [UIApplication sharedApplication];
	thisApp.idleTimerDisabled = !enabled;
}

-(void) showGameOver
{
	// Re-enable screensaver, to prevent battery drain in case the user puts the device aside without turning it off.
	[self setScreenSaverEnabled:YES];
	
	// have everything stop
	CCNode* node;
	CCARRAY_FOREACH([self children], node)
	{
		[node stopAllActions];
	}
	
	// I do want the spiders to keep wiggling so I simply restart this here
	CCSprite* spider;
	CCARRAY_FOREACH(spiders, spider)
	{
		[self runSpiderWiggleSequence:spider];
	}
	
	// disable accelerometer input for the time being
	self.isAccelerometerEnabled = NO;
	// but allow touch input now
	self.isTouchEnabled = YES;
	
	// stop the scheduled selectors
	[self unscheduleAllSelectors];
	
	// add the labels shown during game over
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	CCLabelTTF* gameOver = [CCLabelTTF labelWithString:@"GAME OVER!" fontName:@"Marker Felt" fontSize:60];
	gameOver.position = CGPointMake(screenSize.width / 2, screenSize.height / 3);
	[self addChild:gameOver z:100 tag:100];
	
	// game over label runs 3 different actions at the same time to create the combined effect
	// 1) color tinting
	CCTintTo* tint1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:0];
	CCTintTo* tint2 = [CCTintTo actionWithDuration:2 red:255 green:255 blue:0];
	CCTintTo* tint3 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:0];
	CCTintTo* tint4 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:255];
	CCTintTo* tint5 = [CCTintTo actionWithDuration:2 red:0 green:0 blue:255];
	CCTintTo* tint6 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:255];
	CCSequence* tintSequence = [CCSequence actions:tint1, tint2, tint3, tint4, tint5, tint6, nil];
	CCRepeatForever* repeatTint = [CCRepeatForever actionWithAction:tintSequence];
	[gameOver runAction:repeatTint];
	
	// 2) rotation with ease
	CCRotateTo* rotate1 = [CCRotateTo actionWithDuration:2 angle:3];
	CCEaseBounceInOut* bounce1 = [CCEaseBounceInOut actionWithAction:rotate1];
	CCRotateTo* rotate2 = [CCRotateTo actionWithDuration:2 angle:-3];
	CCEaseBounceInOut* bounce2 = [CCEaseBounceInOut actionWithAction:rotate2];
	CCSequence* rotateSequence = [CCSequence actions:bounce1, bounce2, nil];
	CCRepeatForever* repeatBounce = [CCRepeatForever actionWithAction:rotateSequence];
	[gameOver runAction:repeatBounce];
	
	// 3) jumping
	CCJumpBy* jump = [CCJumpBy actionWithDuration:3 position:CGPointZero height:screenSize.height / 3 jumps:1];
	CCRepeatForever* repeatJump = [CCRepeatForever actionWithAction:jump];
	[gameOver runAction:repeatJump];
	
	// touch to continue label
	CCLabelTTF* touch = [CCLabelTTF labelWithString:@"tap screen to play again" fontName:@"Arial" fontSize:20];
	touch.position = CGPointMake(screenSize.width / 2, screenSize.height / 4);
	[self addChild:touch z:100 tag:101];
	
	// did you try turning it off and on again?
	CCBlink* blink = [CCBlink actionWithDuration:10 blinks:20];
	CCRepeatForever* repeatBlink = [CCRepeatForever actionWithAction:blink];
	[touch runAction:repeatBlink];
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self resetGame];
}

-(void) resetGame
{
	// prevent screensaver from darkening the screen while the game is played
	[self setScreenSaverEnabled:NO];
	
	// remove game over label & touch to continue label
	[self removeChildByTag:100 cleanup:YES];
	[self removeChildByTag:101 cleanup:YES];
	
	// re-enable accelerometer
	self.isAccelerometerEnabled = YES;
	self.isTouchEnabled = NO;
	
	// put all spiders back to top
	[self resetSpiders];
	
	// re-schedule update
	[self scheduleUpdate];
	
	// reset score
	score = 0;
	totalTime = 0;
	[scoreLabel setString:@"0"];
}
-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd),self);
	[spiders release];
	[super dealloc];

}
@end
