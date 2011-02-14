//
//  GameScene.h
//  DoodleDrop
//
//  Created by fernando martinez-gil gutierrez de la Cámara on 06/02/11.
//  Copyright 2011 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"
@interface GameScene : CCLayer {
	CCSprite* player;
	CGPoint playerVelocity;
	
	CCArray* spiders;
	float spiderMoveDuration;
	int numSpidersMoved;
	float totalTime;
	int score;
	CCLabelBMFont *scoreLabel;
}
+(id) scene;
@end
