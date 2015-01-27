//
//  AIModule.h
//  KNB
//
//  Created by Nik Nikonev on 1/23/15.
//  Copyright (c) 2015 Nik Nikonev. All rights reserved.
//

#import <Foundation/Foundation.h>
//
#import "TurnFigureEnum.h"

@interface AIModule : NSObject
+ (instancetype) getInstance;
- (TurnFigure) getResponseForTurn:(TurnFigure)figure;
- (NSInteger) getBalanceOfTurnPlayer:(TurnFigure)pFigure andAiFigure:(TurnFigure)aiFigure;
@end
