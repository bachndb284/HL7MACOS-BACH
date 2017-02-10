//
//  HL7.h
//  HL7 Tester
//
//  Created by Nguyen Bach on 1/2/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HL7Client.h"
#import "HL7Server.h"
@interface HL7WindowController : NSWindowController <HL7ClientDelegate>

@property (strong, nonatomic) IBOutlet NSTextField *serverTextField;
@property (strong, nonatomic) IBOutlet NSTextField *portTextField;
@property (strong, nonatomic) IBOutlet NSTextView *messageTextView;
@property (strong, nonatomic) IBOutlet NSButton *sendButton;
@property (strong, nonatomic) IBOutlet NSTextView *resultTextView;
@property (strong, nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (unsafe_unretained) IBOutlet NSTextView *incomingResult;
@property (strong, nonatomic) IBOutlet NSButton *startServer;


- (IBAction)sendMessage:(id)sender;
- (IBAction)statServer:(id)sender;
@end
