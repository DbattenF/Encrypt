//
//  PublicKeyRSA.h
//  webcampusdocentes
//
//  Created by Sebastia FIorentino on 27/12/2018.
//  Copyright © 2018 Sebastian FIorentino. All rights reserved.
//

@interface PublicKeyRSA : NSObject
+ (NSData*)generateRSAPublicKeyWithModulus:(NSData*)modulus exponent:(NSData*)exponent;
@end


