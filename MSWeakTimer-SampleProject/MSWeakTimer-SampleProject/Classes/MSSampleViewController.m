//
//  MSSampleViewController.m
//  MSWeakTimer-SampleProject
//
//  Created by Javier Soto on 2/12/13.
//  Copyright (c) 2013 MindSnacks. All rights reserved.
//

#import "MSSampleViewController.h"

#import <MSWeakTimer/MSWeakTimer.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    #error this class is only ready to work on iOS6
#endif

@interface MSSampleViewController () <MSWeakTimerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) MSWeakTimer *timer;

@property (strong, nonatomic) MSWeakTimer *backgroundTimer;

@property (strong, nonatomic) dispatch_queue_t privateQueue;

@end

@implementation MSSampleViewController

- (id)init
{
    if ((self = [super init]))
    {
        self.privateQueue = dispatch_queue_create("com.mindsnacks.private_queue", DISPATCH_QUEUE_CONCURRENT);
        
        self.backgroundTimer = [MSWeakTimer scheduledTimerWithTimeInterval:0.2
                                                                    target:self
                                                                  selector:@selector(backgroundTimerDidFire)
                                                                  userInfo:nil
                                                                   repeats:YES
                                                             dispatchQueue:self.privateQueue];
        
    }

    return self;
}

- (void)dealloc
{
    [_timer invalidate];
    [_backgroundTimer invalidate];
}

#pragma mark -

- (IBAction)toggleTimer:(UIButton *)sender
{
    static NSString *kStopTimerText = @"Stop";
    static NSString *kStartTimerText = @"Start";

    NSString *currentTitle = [sender titleForState:UIControlStateNormal];

    if ([currentTitle isEqualToString:kStopTimerText])
    {
        [sender setTitle:kStartTimerText forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }
    else
    {
        [sender setTitle:kStopTimerText forState:UIControlStateNormal];
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:1
                                                        delegate:self
                                                        userInfo:nil
                                                         repeats:YES
                                                   dispatchQueue:dispatch_get_main_queue()];
    }
}

#pragma mark - MSWeakTimerDelegate

- (void)weakTimerDidFire:(MSWeakTimer *)timer
{
    NSAssert([NSThread isMainThread], @"This should be called from the main thread");

    self.label.text = [NSString stringWithFormat:@"%d", [self.label.text integerValue] + 1];
}

#pragma mark -

- (void)backgroundTimerDidFire
{
    NSAssert(![NSThread isMainThread], @"This shouldn't be called from the main thread");

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // dispatch_get_current_queue() is deprecated, but we don't care for this.
        NSAssert(dispatch_get_current_queue() == self.privateQueue, @"This should be called from the private queue");
    #pragma clang diagnostic pop
}

@end