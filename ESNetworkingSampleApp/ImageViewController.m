//
//  ImageViewController.m
//
//  Created by Doug Russell
//  Copyright (c) 2011 Doug Russell. All rights reserved.
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

#import "ImageViewController.h"
#import "SampleNetworkManager.h"

@interface ImageViewController ()
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation ImageViewController

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		self.title = @"Image";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	imageView.backgroundColor = [UIColor blackColor];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.view = imageView;
	self.imageView = imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.titleView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	NSURL *url = [NSURL URLWithString:@"http://farm5.static.flickr.com/4114/4800356319_af057f6467_o.jpg"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	__weak UIProgressView *progressView = (UIProgressView *)self.navigationItem.titleView;
	__weak UIImageView *imageView = self.imageView;
	ESHTTPOperation *op = 
	[ESHTTPOperation newHTTPOperationWithRequest:request
											work:^id<NSObject>(ESHTTPOperation *op, NSError **error) {
												UIImage *image = [UIImage imageWithData:op.responseBody];
												UIImage *scaledImage;
												if (image)
												{
													// This is a ridiculously dumb scale that doesn't do
													// anything with aspect ratio or rotation metadata
													CGSize size = imageView.bounds.size;
													UIGraphicsBeginImageContextWithOptions(size, YES, [[UIScreen mainScreen] scale]);
													[image drawInRect:(CGRect){ { 0.0, 0.0 } , size }];
													scaledImage = UIGraphicsGetImageFromCurrentImageContext();
													UIGraphicsEndImageContext();
												}
												return scaledImage;
											} 
									  completion:^(ESHTTPOperation *op) {
												if (op.error)
												{
													[progressView setProgress:0.0];
													[imageView setImage:nil];
												}
												else
												{
													[progressView setProgress:1.0];
													[imageView setImage:op.processedResponse];
												}
											}];
	op.maximumResponseSize = 10000000;
	[op setDownloadProgressBlock:^(NSUInteger totalBytesRead, NSUInteger totalBytesExpectedToRead) {
		[progressView setProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead)];
	}];
	[[SampleNetworkManager sharedManager] addOperation:op];
}

@end
