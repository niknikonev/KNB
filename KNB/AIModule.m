//
//  AIModule.m
//  KNB
//
//  Created by Nik Nikonev on 1/23/15.
//  Copyright (c) 2015 Nik Nikonev. All rights reserved.
//

#import "AIModule.h"
//

//qsort int comparison function
int int_cmp(const void *a, const void *b)
{
    const NSInteger *ia = (const NSInteger *)a; // casting pointer types
    const NSInteger *ib = (const NSInteger *)b;
    return (int)(*ib  - *ia);
    // integer comparison: returns negative if b > a
    // and positive if a > b
}

struct disbalance
{
    NSInteger val;
    NSInteger idx;
    BOOL nonZeroInHistory;
};

struct body
{
    NSInteger statistics[TurnFigureMaxValue];
};

@interface AIModule ()
{
    struct body stepsAI [TurnFigureMaxValue][TurnFigureMaxValue];
    NSInteger lastSteps[2];
    
    NSInteger stepCount;
}
@end

@implementation AIModule

+ (instancetype) getInstance
{
    static AIModule *module = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        module = [[AIModule alloc] init];
    });
    
    return module;
}

- (instancetype)init
{
    if (self = [super init]) {
        for (NSInteger x=0; x<TurnFigureMaxValue; x++) {
            for (NSInteger y=0; x<TurnFigureMaxValue; x++) {
                for (NSInteger z=0; x<TurnFigureMaxValue; x++) {
                    stepsAI[x][y].statistics[z] = 0;
                }
            }
        }
        
        lastSteps[0] = NSNotFound; lastSteps[1] = NSNotFound;
        
        stepCount = 0;
    }
    
    return self;
}

- (NSInteger) getBalanceOfTurnPlayer:(TurnFigure)pFigure andAiFigure:(TurnFigure)aiFigure
{
    //TurnFigureRock = 0,
    //TurnFigurePaper = 1,
    //TurnFigureScissors = 2,
    //TurnFigureSpock = 3,
    //TurnFigureLizard = 4,
    NSInteger balanceMatrix [TurnFigureMaxValue][TurnFigureMaxValue] = {
        //    r   p   sc sp   li
        { 0, -1,  1, -1,  1}, // r
        { 1,  0, -1,  1, -1}, // p
        {-1,  1,  0, -1,  1}, // sc
        { 1, -1,  1,  0, -1}, // sp
        {-1,  1, -1,  1,  0}, // li
    };
    
    if (pFigure == aiFigure)
        return 0;
    
    return balanceMatrix[pFigure][aiFigure];
}

- (TurnFigure) getResponseForTurn:(TurnFigure)figure
{
    // search resonable answer for history
    // analyse statistic to response
    NSInteger x = NSNotFound, y=NSNotFound;
    if (stepCount>0)
        x = lastSteps[0];
    if (stepCount>1)
        y = lastSteps[1];
    
    NSInteger response = NSNotFound;
    NSInteger availableResponses[TurnFigureMaxValue];
    NSInteger balanceForResponse[TurnFigureMaxValue];
    
    for (NSInteger i=0; i<TurnFigureMaxValue; i++) {
        availableResponses[i] = 0;
        balanceForResponse[i] = 0;
    }
    
    struct disbalance minimumDisbalance = {
        .val = NSNotFound,
        .idx = NSNotFound
    };
    
    NSInteger weightOfAllResponses = 0;
    if ((x != NSNotFound)&&(y != NSNotFound)) {
        for (NSInteger i=0; i<TurnFigureMaxValue; i++) {
            availableResponses[i] = stepsAI[x][y].statistics[i];
        }
        
        // check posible balance for all responses
        for (NSInteger a=0; a<TurnFigureMaxValue; a++) {
            balanceForResponse[a] = 0;
            
            for (NSInteger b=0; b<TurnFigureMaxValue; b++) {
                balanceForResponse[a] += ((availableResponses[b])*([self getBalanceOfTurnPlayer:a andAiFigure:b]));
            }
        }
        
        //qsort(availableResponses, 3, sizeof(NSInteger), int_cmp);
        struct disbalance findedMinimumDisbalance = {
            .val = balanceForResponse[0],
            .idx = 0,
            .nonZeroInHistory = (balanceForResponse[0] != 0)
        };
        
        NSInteger idx = 0;
        for (idx = 0; idx<TurnFigureMaxValue; idx++) {
            if (balanceForResponse[idx]>findedMinimumDisbalance.val) {
                findedMinimumDisbalance.val = balanceForResponse[idx];
                findedMinimumDisbalance.idx = 0;
                findedMinimumDisbalance.nonZeroInHistory = (balanceForResponse[idx] != 0);
            }
            
            if (balanceForResponse[idx]>0){
                weightOfAllResponses += balanceForResponse[idx];
            } else
                continue;
        }
        
        minimumDisbalance = findedMinimumDisbalance;
    }
    
    if (weightOfAllResponses == 0) {
        if (minimumDisbalance.val != NSNotFound) {
            if (minimumDisbalance.nonZeroInHistory) {
                response = minimumDisbalance.idx;
            } else {
                arc4random_uniform((u_int32_t)TurnFigureMaxValue);
                if (stepCount > 1)
                    response = (arc4random_uniform(2))?lastSteps[0]:lastSteps[1];
            }
        } else {
            arc4random_uniform((u_int32_t)TurnFigureMaxValue);
            if (stepCount > 1)
                response = (arc4random_uniform(2))?lastSteps[0]:lastSteps[1];
        }
    } else {
        NSInteger destWeight = arc4random_uniform((u_int32_t)weightOfAllResponses) + 1;
        
        NSInteger selectIdx = NSNotFound;
        for (NSInteger i=0; i<TurnFigureMaxValue; i++) {
            if (balanceForResponse[i] <= 0)
                continue;
            
            destWeight -= balanceForResponse[i];
            
            if (destWeight <= 0) {
                selectIdx = i;
                break;
            }
        }
        
        if (selectIdx != NSNotFound)
            response = selectIdx;
    }
    
    if ((response == NSNotFound)||
        (response >= TurnFigureMaxValue)) {
        response = arc4random_uniform((u_int32_t)TurnFigureMaxValue);
    }
    
    [self addTurnToHistory:figure];
    
    return (TurnFigure)response;
}

- (void) addTurnToHistory:(TurnFigure)figure
{
    NSInteger idxFigure = (NSInteger)figure;
    
    // matrix of statistics
    if (stepCount > 1) {
        stepsAI[lastSteps[0]] [lastSteps[1]].statistics[figure] += 1;
    }
    
    // add to last steps
    if (stepCount > 1) {
        lastSteps[0] = lastSteps[1];
        lastSteps[1] = idxFigure;
    } else {
        lastSteps[stepCount] = idxFigure;
    }
    stepCount++;
}

@end


/*
 switch (selectIdx) {
 case TurnFigureRock:
 response = (arc4random_uniform(2))?TurnFigurePaper:TurnFigureSpock;
 break;
 case TurnFigurePaper:
 response = (arc4random_uniform(2))?TurnFigureScissors:TurnFigureLizard;
 break;
 case TurnFigureScissors:
 response = (arc4random_uniform(2))?TurnFigureRock:TurnFigureSpock;
 break;
 case TurnFigureSpock:
 response = (arc4random_uniform(2))?TurnFigurePaper:TurnFigureLizard;
 break;
 case TurnFigureLizard:
 response = (arc4random_uniform(2))?TurnFigureRock:TurnFigureScissors;
 break;
 default:
 response = NSNotFound;
 break;
 }
 */
