//
//  ComViewModel.h
//  ReactiveObjCDemo
//
//  Created by dage on 2018/12/31.
//  Copyright © 2018 OnlyStu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComViewModel : NSObject

@property (copy, nonatomic) NSString *name;

@property (assign, nonatomic) NSUInteger score;
@property (assign, nonatomic) NSUInteger stepAmount;
@property (assign, nonatomic) NSUInteger maxScore;
@property (assign, nonatomic) NSUInteger minScore;

@property (assign, nonatomic, readonly) NSUInteger maxScoreUpdates;


- (RACSignal *)forbiddenNameSignal;
- (RACSignal *)modelIsValidSignal;

- (void)defaultSetting;
- (void)uploadData;

@end

NS_ASSUME_NONNULL_END
