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
		scoreLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Arial" fontSize:48];
		scoreLabel.position = CGPointMake(screenSize.width/2, screenSize.height);
		scoreLabel.anchorPoint = CGPointMake(0.5f, 1.0f);
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
		score = currentTime;
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
			[self resetSpiders];
		}
	}
}
-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd),self);
	[spiders release];
	[super dealloc];

}
@end
