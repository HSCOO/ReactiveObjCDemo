//
//  ComViewModel.m
//  ReactiveObjCDemo
//
//  Created by dage on 2018/12/31.
//  Copyright © 2018 OnlyStu. All rights reserved.
//

#import "ComViewModel.h"

@interface ComViewModel()

@property (strong, nonatomic) NSArray *forbiddenNames;
@property (assign, nonatomic ,readwrite) NSUInteger maxScoreUpdates;

@end

@implementation ComViewModel

- (instancetype)init{
    if (self = [super init]) {
        
        _name = @"AAA";
        _score = 100;
        _stepAmount = 1;
        _maxScore = 10000;
        _minScore = 0;
        
        _maxScoreUpdates = 10;
        
        _forbiddenNames = @[
                            @"dag",
                            @"adrn",
                            @"poop"
                            ];
    }
    return self;
}

- (void)defaultSetting{
    self.name = @"AAA";
    self.score = 100;
    self.stepAmount = 1;//步进值
    self.maxScore = 10000;
    self.minScore = 0;
    
    self.maxScoreUpdates = 10;
    
    self.forbiddenNames = @[
                        @"dag",
                        @"adrn",
                        @"poop"
                        ];
}

- (void)uploadData{
    @weakify(self);
    // 模拟网络请求，并且改变name、score，可以测试动绑定值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        self.name = @"xxxxxxxx";
        self.score = 1314;
        
        NSString *msg = [NSString stringWithFormat:@"Update %@ with %.0ld score",self.name,self.score];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Successfull" message:msg delegate:nil
                                              cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    });
}

- (RACSignal *)forbiddenNameSignal{
    @weakify(self);
    return [RACObserve(self, name) filter:^BOOL(NSString *newName) {
        @strongify(self);
        return [self.forbiddenNames containsObject:newName];
    }];
}

- (RACSignal *)modelIsValidSignal{
    @weakify(self);
    return [RACSignal combineLatest:@[RACObserve(self, name), RACObserve(self, score)] reduce:^id _Nonnull(NSString *newName, NSNumber *newScore){
        @strongify(self);
        return @(newName.length > 0 &&
                ![self.forbiddenNames containsObject:newName] &&
                newScore.integerValue >= self.minScore);
    }];
}

@end
