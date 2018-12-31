//
//  CombinationViewController.m
//  ReactiveObjCDemo
//
//  Created by dage on 2018/12/30.
//  Copyright © 2018 OnlyStu. All rights reserved.
//

#import "CombinationViewController.h"
#import "ComViewModel.h"

static NSUInteger const kMaxUploader = 5;

@interface CombinationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIStepper *scoreStepper;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@property (strong, nonatomic) ComViewModel *viewModel;
@property (assign, nonatomic) NSUInteger scoreUpdates;

@end

@implementation CombinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self combinaSetting];
}

- (void)combinaSetting{
    @weakify(self);
#if 0
    // 双向绑定，这个可以实时更新
    RAC(self.nameTextField, text) = RACObserve(self.viewModel, name);
    [self.nameTextField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        NSLog(@"x -- %@",x);
        self.viewModel.name = x;
    }];
#else
    // 双向绑定，只有输入完成后，才会更新
    RACChannelTo(self.nameTextField, text) = RACChannelTo(self.viewModel, name);
#endif
    
    // 转换类型， number -> string
    RAC(self.scoreLabel, text) = [RACObserve(self.viewModel, score) map:^id _Nullable(NSNumber *value) {
        return [value stringValue];
    }];
    
    // 双向绑定
    RACChannelTo(self.scoreStepper, value) = RACChannelTo(self.viewModel, score);
    
    RAC(self.scoreStepper,stepValue) = RACObserve(self.viewModel, stepAmount);
    RAC(self.scoreStepper,maximumValue) = RACObserve(self.viewModel, maxScore);
    RAC(self.scoreStepper,minimumValue) = RACObserve(self.viewModel, minScore);
    RAC(self.scoreStepper,hidden) = [RACObserve(self, scoreUpdates) map:^id _Nullable(NSNumber *value) {
        return @(value.integerValue >= self.viewModel.maxScoreUpdates);
    }];
    
    [[[RACObserve(self.scoreStepper, value) skip:1] take:self.viewModel.maxScoreUpdates]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self);
         self.scoreUpdates++;
     }];
    
    [self.viewModel.forbiddenNameSignal subscribeNext:^(id  _Nullable x) {
        // 清除name
        self.viewModel.name = @"";
        UIAlertController *alertVC = [CSAlertManager alertText:[NSString stringWithFormat:@"The name %@ has been forbidden!",x]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }];
    
    // updateBtn
    RAC(self.updateBtn, enabled) = self.viewModel.modelIsValidSignal;
    // 点击事件绑定在viewmodel上，
    [self.updateBtn addTarget:self.viewModel action:@selector(uploadData) forControlEvents:UIControlEventTouchUpInside];
    
    [[[self.updateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] skip:kMaxUploader - 1] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
        self.nameTextField.enabled = NO;
        self.scoreStepper.hidden = self.updateBtn.hidden = YES;
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - setter&getter

- (ComViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[ComViewModel alloc] init];
    }
    return _viewModel;
}

@end
