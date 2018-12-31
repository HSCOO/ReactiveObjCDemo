//
//  SimpleViewController.m
//  ReactiveObjCDemo
//
//  Created by dage on 2018/12/29.
//  Copyright © 2018 OnlyStu. All rights reserved.
//

#import "SimpleViewController.h"

@interface SimpleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfiTextField;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;

@end

@implementation SimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self testUsername];
    
//    [self testBinding];
    [self testBtn];
    [self testMerge];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)testUsername{
    
    // kvo的实现，只会在text改变后触发，正在输入时不触发
    [RACObserve(self.username, text) subscribeNext:^(NSString *text) {
        NSLog(@"username final -- %@",text);
    }];
    
    // 动态变化
    [[self.username rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"username changing -- %@",x);
    }];
    
    // 信号有一个特点，可以使用高阶的函数来做筛选、遍历
    
    // 检查用户名以j开头的才继续处理
    [[RACObserve(self.username, text) filter:^BOOL(id  _Nullable value) {
        // 需要返回一个BOOL
        return [value hasPrefix:@"j"];
    }]
     subscribeNext:^(id  _Nullable x) {
         NSLog(@"以j开头的用户名 -- %@",x);
     }];
}

// 绑定
- (void)testBinding{
    // 注册按钮是否点击，依赖了三个信号
    // combineLatest可以传递多个信号
    // RAC宏接收的也是一个信号量
    RAC(self.createBtn,enabled) = [RACSignal combineLatest:@[RACObserve(self.username,text),RACObserve(self.passwordTextField, text),RACObserve(self.passwordConfiTextField, text)]
                                   
      // 只有每个输入框有值，并且密码和确认密码相同时，返回YES
    reduce:^id _Nonnull(NSString *username,NSString *password, NSString *passwordConfi){
        return @(username.length > 0 && password.length > 0 && passwordConfi.length > 0 && [password isEqualToString:passwordConfi]);
    }];
    
    // 处理按钮点击事件
    [[self.createBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"btn click");
    }];
}

- (void)testBtn{
    RACCommand *creatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            // 模仿异步请求
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"异步请求结束");
                // 可以传递值出去
                [subscriber sendNext:@"create success"];
                [subscriber sendCompleted];
            });
            
            return nil;
        }];
    }];
    
    [creatCommand.executionSignals subscribeNext:^(RACSignal *signal) {
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"得到异步传递过来的值 -- %@",x);
        }];
    }];
    
    self.createBtn.rac_command = creatCommand;
}

- (void)testMerge{
    [[RACSignal merge:@[RACObserve(self.username,text),RACObserve(self.passwordTextField, text),RACObserve(self.passwordConfiTextField, text)]] subscribeNext:^(id  _Nullable x) {
        NSLog(@"所有信号");
    }];
    
    [[[self.username.rac_textSignal then:^RACSignal * _Nonnull{
        return nil;
    }] flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return nil;
    }] subscribeError:^(NSError * _Nullable error) {
        
    }];
}



@end
