//
//  HL7Server.h
//  HL7 Tool
//
//  Created by Nguyen Bach on 1/20/17.
//  Copyright © 2017 Miles Hollingsworth. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
@interface HL7Server : NSThread
{
    CFSocketRef obj_server;
    @public
    NSTextField *txrecv;
}
-(void)InitializeServer;
-(void)main;
-(void)StopServer;
@end
