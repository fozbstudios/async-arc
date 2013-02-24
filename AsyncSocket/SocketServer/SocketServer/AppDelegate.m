//
//  AppDelegate.m
//  SocketServer
//
//  Created by Cayden Liew on 11/15/11.
//  Copyright (c) 2011 Cayden Liew. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"


@implementation AppDelegate

@synthesize window = _window;

	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
	
	// Create our socket.
	// We tell it to invoke our delegate methods on the main thread.
	
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	// Create an array to hold accepted incoming connections.
	
	connectedSockets = [[NSMutableArray alloc] init];
	
	// Now we tell the socket to accept incoming connections.
	// We don't care what port it listens on, so we pass zero for the port number.
	// This allows the operating system to automatically assign us an available port.
	
	NSError *err = nil;
	if ([asyncSocket acceptOnPort:0 error:&err])
	{
		// So what port did the OS give us?
		
		UInt16 port = [asyncSocket localPort];
		
		// Create and publish the bonjour service.
		// Obviously you will be using your own custom service type.
		
		netService = [[NSNetService alloc] initWithDomain:@"local."
		                                             type:@"_YourServiceName._tcp."
		                                             name:@""
		                                             port:port];
		
		[netService setDelegate:self];
		[netService publish];
		
		// You can optionally add TXT record stuff
		
		NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
		
		txtDict[@"cow"] = @"moo";
		txtDict[@"duck"] = @"quack";
		
		NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
		[netService setTXTRecordData:txtData];
	}
	else
	{
		NSLog(@"Error in acceptOnPort:error: -> %@", err);
	}
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
	
	// The newSocket automatically inherits its delegate & delegateQueue from its parent.
	
	[connectedSockets addObject:newSocket];
	NSString *welcomeMsg = @"Reply from server: you are connected to server.\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[newSocket writeData:welcomeData withTimeout:-1 tag:0];
	
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:15.0 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Data received from client: %@",str);
	
	NSString *datastr = [NSString stringWithFormat:@"Reply from server: you send - %@ \r\n", str];
	NSData *_data = [datastr dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:_data withTimeout:-1 tag:2];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:30.0 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[connectedSockets removeObject:sock];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
			  [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
	// Override me to do something here...
	// 
	// Note: This method in invoked on our bonjour thread.
	
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
               [ns domain], [ns type], [ns name], errorDict);
}

@end
