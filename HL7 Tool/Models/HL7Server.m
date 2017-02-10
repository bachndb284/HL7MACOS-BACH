//
//  HL7Server.m
//  HL7 Tool
//
//  Created by Nguyen Bach on 1/20/17.
//  Copyright © 2017 Miles Hollingsworth. All rights reserved.
//

#import "HL7Server.h"
#import "HL7Client.h"
@implementation HL7Server

-(void)InitializeServer:(NSTextField *) target_text_field{
    txrecv=target_text_field;
    CFSocketContext sctx={0,(__bridge void *)(self),NULL,NULL,NULL};
    obj_server=CFSocketCreate(kCFAllocatorDefault, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerCallBackHandler, &sctx);
    int so_reuse_flag=1;
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEADDR, &so_reuse_flag, sizeof(so_reuse_flag));
    setsockopt(CFSocketGetNative(obj_server), SOL_SOCKET, SO_REUSEPORT, &so_reuse_flag, sizeof(so_reuse_flag));
    struct sockaddr_in sock_addr;
    memset(&sock_addr, 0, sizeof(sock_addr));
    sock_addr.sin_len=sizeof(sock_addr);
    sock_addr.sin_family=AF_INET;
    sock_addr.sin_port=htons(49554);
    sock_addr.sin_addr.s_addr=INADDR_ANY;
    
    CFDataRef dref=CFDataCreate(kCFAllocatorDefault, (UInt8*)&sock_addr, sizeof(sock_addr));
    CFSocketSetAddress(obj_server, dref);
    CFRelease(dref);
}

-(void)main{
    CFRunLoopSourceRef loopref=CFSocketCreateRunLoopSource(kCFAllocatorDefault, obj_server, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), loopref, kCFRunLoopDefaultMode);
    CFRelease(loopref);
    CFRunLoopRun();
}

-(void)StopServer{
    CFSocketInvalidate(obj_server);
    CFRelease(obj_server);
    CFRunLoopStop(CFRunLoopGetCurrent());
}

void TCPServerCallBackHandler(CFSocketRef s, CFSocketCallBackType callbacktype,CFDataRef address, const void *data,void *info){
    switch (callbacktype) {
        case kCFSocketAcceptCallBack:
        {
            HL7Server * obj_server_ptr=(__bridge HL7Server *)info;
            HL7Server * obj_accepted_socket=[[HL7Client alloc]init];
          //  [obj_accepted_socket InitializeNative:*(CFSocketNativeHandle*)data showRecvData:obj_server_ptr->txrecv];
            
            [obj_accepted_socket start];
        }
            break;
            
        default:
            break;
    }
}
@end
