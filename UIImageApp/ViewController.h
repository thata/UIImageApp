//
//  ViewController.h
//  UIImageApp
//
//  Created by thata on 2013/03/21.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
- (IBAction)copyImage:(id)sender;
- (IBAction)copyImage2:(id)sender;
- (IBAction)grayscaleImage:(id)sender;
- (IBAction)negativeImage:(id)sender;

@end
