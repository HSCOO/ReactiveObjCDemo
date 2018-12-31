//
//  CSAlertManager.m
//  ReactiveObjCDemo
//
//  Created by dage on 2018/12/31.
//  Copyright © 2018 OnlyStu. All rights reserved.
//

#import "CSAlertManager.h"

@implementation CSAlertManager

+ (UIAlertController *)alertText:(NSString *)text{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:text message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    return alert;
}

@end
