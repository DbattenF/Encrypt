//
//  GetPubKey.h
//  RSAApp
//
//  Created by OK on 2/1/2019.
//  Copyright © 2019 OK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetPubKey : NSObject

+ (NSData * __nullable)generateRSAPublicKeyWithModulus:(NSData * __nonnull)modulus exponent:(NSData * __nonnull)exponent;

@end

NS_ASSUME_NONNULL_END
