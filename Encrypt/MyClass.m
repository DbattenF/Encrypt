//
//  MyClass.m
//  Encrypt
//
//  Created by Sebastian FIorentino on 03/04/2019.
//  Copyright © 2019 Sebastian FIorentino. All rights reserved.
//

#import "MyClass.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MyClass

+ (NSString *)myMethod {
    NSString *key = @"test";
    NSString *data = @"mytestdata";
    const char *ckey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cdata = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char chmac[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, ckey, strlen(ckey), cdata, strlen(cdata), chmac);
    NSData *hmac = [[NSData alloc] initWithBytes:chmac length:sizeof(chmac)];
    NSString *hash = [hmac base64Encoding];
    return hash;
}

@end
