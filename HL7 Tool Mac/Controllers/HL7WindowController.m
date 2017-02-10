//
//  HL7.m
//  HL7 Tester
//
//  Created by Nguyen Bach on 1/2/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

#import "HL7WindowController.h"
#import "HL7Message.h"
#import "HL7Client.h"

@interface HL7WindowController ()

@property (strong, nonatomic) HL7Client *client;

- (void)startProgressIndicator;
- (void)stopProgressIndicator;

@end

@implementation HL7WindowController

- (IBAction)sendMessage:(id)sender
{
    self.client = [HL7Client clientWithServer:[self.serverTextField stringValue] andPort:[self.portTextField stringValue]];
    
    if (!self.client) {
        [self.resultTextView setString:@"Invalid host"];
        [self.incomingResult setString:@"Try Again!!!"];
        return;
    }
    
    [self.sendButton setEnabled:NO];
    [self startProgressIndicator];
    
    self.client = [HL7Client clientWithServer:[self.serverTextField stringValue] andPort:[self.portTextField stringValue]];
    self.client.delegate = self;
    [self.client sendMessage:[self.messageTextView string]];
}

- (void)startProgressIndicator {
    [self.progressIndicator startAnimation:self];
    [self.progressIndicator setHidden:NO];
}

- (void)stopProgressIndicator {
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator stopAnimation:self];
}

#pragma mark HL7ClientDelegate methods

- (void)client:(HL7Client *)sender didReachResult:(NSString *)resultString {
    [self stopProgressIndicator];
    [self.resultTextView setString:[resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    //self.incomingResult.string = self.messageTextView.string;
    [self.sendButton setEnabled:YES];
}
- (void)client:(HL7Client *)sender didReachIncomingResult:(NSString *)IncomingResultString {
    [self stopProgressIndicator];
    [self.incomingResult setString:[IncomingResultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    //self.incomingResult.string = self.messageTextView.string;
    [self.sendButton setEnabled:YES];
}


@end
