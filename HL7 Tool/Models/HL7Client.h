//
//  HL7MLLPClient.h
//  HL7 Tool
//
//  Created by Nguyen Bach on 1/2/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HL7ClientDelegate;

@interface HL7Client : NSObject <NSStreamDelegate>

@property (weak, nonatomic) id <HL7ClientDelegate> delegate;

+ (instancetype)clientWithServer:(NSString *)server andPort:(NSString *)port;
- (void) sendMessage:(NSString *)messsageString;

@end

@protocol HL7ClientDelegate <NSObject>

- (void)client:(HL7Client *)sender didReachResult:(NSString *)resultString;
- (void)client:(HL7Client *)sender didReachIncomingResult:(NSString *)IncomingResultString;
//- (void)client:(HL7Client *)sender didReadData:(NSData *)receiveData;

@end
