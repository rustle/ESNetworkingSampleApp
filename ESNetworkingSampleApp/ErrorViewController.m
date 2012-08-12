//
//  ErrorViewController.m
//
//  Created by Doug Russell
//  Copyright (c) 2012 Doug Russell. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ErrorViewController.h"
#import "SampleNetworkManager.h"

@interface ErrorViewController ()

@end

@implementation ErrorViewController

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		self.title = @"Error";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.titleView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	NSURL *url = [NSURL URLWithString:@"http://httpbin.org/delay/15"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setTimeoutInterval:5.0];
	__weak UIProgressView *progressView = (UIProgressView *)self.navigationItem.titleView;
	ESHTTPOperation *op =
	[ESHTTPOperation newHTTPOperationWithRequest:request
											work:nil
									  completion:^(ESHTTPOperation *op) {
										  if (op.error)
										  {
											  [progressView setProgress:0.0];
											  [[[UIAlertView alloc] initWithTitle:[op.error domain] message:[op.error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
										  }
										  else
										  {
											  [progressView setProgress:1.0];
										  }
									  }];
	[op setDownloadProgressBlock:^(NSUInteger totalBytesRead, NSUInteger totalBytesExpectedToRead) {
		[progressView setProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead)];
	}];
	[[SampleNetworkManager sharedManager] addOperation:op];
}

@end
