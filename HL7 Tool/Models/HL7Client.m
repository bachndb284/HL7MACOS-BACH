//
//  HL7MLLPClient.m
//  HL7 Tool
//
//  Created by Nguyen Bach on 1/2/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

#import "HL7Client.h"
#import "HL7Message.h"

@interface HL7Client ()

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) NSString *serverString;
@property (strong, nonatomic) NSString *portString;
- (void)startServer;
- (void)createStreams;
- (void)openStreams;
- (void)timeoutStreams;
- (BOOL)isHostValid;

@end

@implementation HL7Client

+ (instancetype)clientWithServer:(NSString *)server andPort:(NSString *)port {
    HL7Client *client = [[HL7Client alloc] init];
    if (client) {
        client.serverString = server;
        client.portString = port;
        
        if(![client isHostValid]) {
            return nil;
        }
    }
    
    return client;
}

- (BOOL)isHostValid {
    if([self.serverString length] == 0 || [self.portString length] == 0) {
        return NO;
    }
    
    
    NSCharacterSet *invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange invalidCharactersRange = [self.serverString rangeOfCharacterFromSet:invalidCharacters];
    if(invalidCharactersRange.length != 0) {
        return NO;
    }
    
    if ([self.portString intValue] < 0 || [self.portString intValue] > 65536) {
        return NO;
    }
    
    __block BOOL result = YES;
    NSArray *hostOctetArray = [self.serverString componentsSeparatedByString:@"."];
    
    if ([hostOctetArray count] != 4) {
        return NO;
    }
    
    [hostOctetArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger octet = [(NSString *)obj integerValue];
        if (octet < 0 || octet > 255) {
            result = NO;
        }
    }];
    
    return result;
}


- (void)sendMessage:(NSString *)messageString {
    self.messageString = messageString;
    [self createStreams];
    [self openStreams];
    NSData *dt = [[NSData alloc] initWithData:[messageString dataUsingEncoding:NSASCIIStringEncoding]];
    [_outputStream write:[dt bytes] maxLength:[dt length]];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                         target:self
                                                       selector:NSSelectorFromString(@"timeoutStreams")
                                                       userInfo:NULL
                                                        repeats:NO];
}

//-(void)messageReceived:(NSString *)m

-(void)startServer{
    NSSocketPort *socketPort;
    socketPort = [[NSSocketPort alloc] initWithTCPPort: 49582];
    NSConnection * theConnection;
    theConnection = [[NSConnection alloc] initWithReceivePort:socketPort sendPort:nil];
    theConnection = [[NSConnection alloc] init];
    [theConnection setRootObject:self];
    [theConnection registerName:@"Server Connection"];
}
- (void)createStreams {
 
    
    CFWriteStreamRef writeStream;
    CFReadStreamRef readStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.serverString, (UInt32)[self.portString intValue], &readStream, &writeStream);
    
    self.inputStream = (__bridge_transfer NSInputStream *)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
    self.outputStream.delegate = self;
    self.inputStream.delegate = self;
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)openStreams {
    [self.outputStream open];
    [self.inputStream open];
}

- (void)closeStreams {
    [self.outputStream close];
    [self.inputStream close];
}

- (void)timeoutStreams {
    [self closeStreams];
    [self.delegate client:self didReachResult:@"Connection timed out"];
    [self.delegate client:self didReachIncomingResult:@"Please try Again!!!"];
    
    
}

#pragma mark NSStreamDelegate Methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
            
		case NSStreamEventOpenCompleted:
            if ([self.timeoutTimer isValid]) {
                [self.timeoutTimer invalidate];
            }
			break;
            
        case NSStreamEventHasSpaceAvailable:
        {
            HL7Message *message = [HL7Message messageWithString:self.messageString];
            
            [self.outputStream write:[message bytes]
                           maxLength:[message length]];
            
            [aStream close];
			break;
        }
            
        case NSStreamEventHasBytesAvailable:
        {
            NSMutableData *receivedData = [[NSMutableData alloc] init];
            
            while ([self.inputStream hasBytesAvailable]) {
                uint8_t buf[1024];
                NSInteger len = [(NSInputStream *)aStream read:buf maxLength:1024];
               
                [receivedData appendBytes:(const void *)buf length:len];
            
            
            if ([receivedData length]) {
                [self.delegate client:self didReachResult:[[NSString alloc] initWithData:receivedData
                                                                                encoding:NSUTF8StringEncoding]];
//                [self.delegate client:self didReachIncomingResult:[[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding]];
                [self.delegate client:self didReachIncomingResult:self.messageString];
            
            } else {
                [self.delegate client:self didReachResult:@"Message sent with no response"];
                [self.delegate client:self didReachIncomingResult:@"Please try Again!!!"];
            }
            }
            [aStream close];
            break;
        }
            
		case NSStreamEventErrorOccurred:
            [aStream close];
            [self.delegate client:self didReachResult:@"Can not connect to the host"];
            [self.delegate client:self didReachIncomingResult:@"Please try Again!!!"];
			break;
            
		case NSStreamEventEndEncountered:
        {
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
       
            aStream = nil;
			break;
        }
		default:
            [aStream close];
            [self.delegate client:self didReachResult:@"Unknown error"];
            [self.delegate client:self didReachIncomingResult:@"Please try Again!!!"];
    }
}

@end
