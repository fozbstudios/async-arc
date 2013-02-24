//
//  ViewController.m
//  SocketClient
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)sendData {
    if (asyncSocket == nil) {
        asyncSocket = [(AppDelegate *)[[UIApplication sharedApplication] delegate] asyncSocket];
        asyncSocket.delegate = self;
    }
    
    NSString *dataSend = [NSString stringWithFormat:@"%@\r\n", @"test"];
	NSData *data = [dataSend dataUsingEncoding:NSUTF8StringEncoding];
	
    //write data to server
	[asyncSocket writeData:data withTimeout:-1 tag:0];
    //listen to server for message
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:30.0 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //data from server
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //prepare to read the next message from server again
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:30.0 tag:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
