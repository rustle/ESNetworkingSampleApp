//
//  WebViewController.m
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

#import "WebViewController.h"
#import "SampleNetworkManager.h"

@interface WebViewController () <UIWebViewDelegate>
@property (nonatomic) UIWebView *webView;
@end

@implementation WebViewController

- (instancetype)init
{
    self = [super init];
    if (self)
	{
		self.title = @"Web";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	webView.delegate = self;
	webView.scalesPageToFit = YES;
	self.view = webView;
	self.webView = webView;
}

- (void)dealloc
{
	self.webView.delegate = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	NSURL *url = [NSURL URLWithString:@"http://www.getitdownonpaper.com/"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	__weak UIProgressView *progressView = (UIProgressView *)self.navigationItem.titleView;
	__weak UIWebView *webView = self.webView;
	ESHTTPOperation *op = 
	[ESHTTPOperation newHTTPOperationWithRequest:request
											work:nil 
									  completion:^(ESHTTPOperation *op) {
										  if (op.error)
										  {
											  [progressView setProgress:0.0];
											  [webView loadHTMLString:[NSString stringWithFormat:@"<H2>BAD THING!!!</H2><p>%@</p>", op.error] baseURL:nil];
										  }
										  else
										  {
											  [progressView setProgress:0.9];
											  [webView loadData:op.responseBody 
													   MIMEType:@"text/html" 
											   textEncodingName:[NSString localizedNameOfStringEncoding:NSUTF8StringEncoding] 
														baseURL:[NSURL URLWithString:@"http://www.getitdownonpaper.com"]];
										  }
									  }];
	[op setDownloadProgressBlock:^(NSUInteger totalBytesRead, NSUInteger totalBytesExpectedToRead) {
		[progressView setProgress:((float)totalBytesRead/(float)totalBytesExpectedToRead) * 0.9];
	}];
	[[SampleNetworkManager sharedManager] addOperation:op];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	((UIProgressView *)self.navigationItem.titleView).progress = 1.0;
}

@end
