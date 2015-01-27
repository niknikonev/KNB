//
//  ViewController.m
//  KNB
//
//  Created by Nik Nikonev on 1/23/15.
//  Copyright (c) 2015 Nik Nikonev. All rights reserved.
//

#import "ViewController.h"
//
#import "AIModule.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *balanceLbl;
@property (strong, nonatomic) IBOutlet UILabel *difficultyLbl;
@property (strong, nonatomic) IBOutlet UIImageView *aiTurnImageView;
@property (strong, nonatomic) IBOutlet UIButton *rockBtn;
@property (strong, nonatomic) IBOutlet UIButton *paperBtn;
@property (strong, nonatomic) IBOutlet UIButton *scissorsBtn;
@property (strong, nonatomic) IBOutlet UIButton *spockBtn;
@property (strong, nonatomic) IBOutlet UIButton *lizardBtn;
//
@property (nonatomic, assign) NSInteger balance;
@property (nonatomic, assign) NSInteger turnCnt;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.balanceLbl setText: @"Balance: 0"];
    [self.difficultyLbl setText:@""];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rockTurnAction:(id)sender {
    [self logicActionForTurn:TurnFigureRock];
}

- (IBAction)paperTurnAction:(id)sender {
    [self logicActionForTurn:TurnFigurePaper];
}

- (IBAction)scissorsBtn:(id)sender {
    [self logicActionForTurn:TurnFigureScissors];
}

- (IBAction)spockBtn:(id)sender {
    [self logicActionForTurn:TurnFigureSpock];
}

- (IBAction)lizardBtn:(id)sender {
    [self logicActionForTurn:TurnFigureLizard];
}

- (void) logicActionForTurn:(TurnFigure) figure
{
    [self.view setUserInteractionEnabled:NO];
    
    AIModule *ai = [AIModule getInstance];
    TurnFigure response;
    response = [ai getResponseForTurn:figure];
    
    // show response
   
    switch (response) {
        case TurnFigureRock:{
            [self.aiTurnImageView setImage:[UIImage imageNamed:@"0"]];
        }
            break;
        case TurnFigurePaper:{
            [self.aiTurnImageView setImage:[UIImage imageNamed:@"1"]];
        }
            break;
        case TurnFigureScissors:{
            [self.aiTurnImageView setImage:[UIImage imageNamed:@"2"]];
        }
            break;
        case TurnFigureSpock:{
            [self.aiTurnImageView setImage:[UIImage imageNamed:@"3"]];
        }
            break;
        case TurnFigureLizard:{
            [self.aiTurnImageView setImage:[UIImage imageNamed:@"4"]];
        }
            break;
        default:
            break;
    }
    
    [self.aiTurnImageView setAlpha:0.02f];
    [UIView animateWithDuration:0.3 animations:^{
        [self.aiTurnImageView setAlpha:1.0f];
    }];
    
    // calculate balance of answer
    NSInteger added = [ai getBalanceOfTurnPlayer:figure andAiFigure:response];
    
    self.balance += added;
    
    [self.balanceLbl setText:[NSString stringWithFormat: @"Balance: %ld for turn: %ld", (long)self.balance, (long)self.turnCnt]];
    self.turnCnt += 1;
    
    [self.difficultyLbl setText:[NSString stringWithFormat: @"T: %ld", (long)added]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view setUserInteractionEnabled:YES];
    });
}

@end
