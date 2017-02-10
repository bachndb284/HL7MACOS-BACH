//
//  HL7Message.h
//  HL7 Tester
//
//  Created by Nguyen Bach on 1/2/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HL7Message : NSObject

+ (instancetype)messageWithString:(NSString *)aString;
- (const void *)bytes;
- (NSUInteger)length;

@end
