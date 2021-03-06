//
//  CryptoUtil.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 01. 16.
//
//  last update: 12.07.16.
//

#import "CryptoUtil.h"

#import "KeychainUtil.h"

#import "Base64.h"

@implementation CryptoUtil

#pragma mark -
#pragma mark RSA key-related functions

+ (BOOL)generateRSAKeyWithKeySizeInBits:(int)keyBits publicKeyTag:(NSString*)publicTag privateKeyTag:(NSString*)privateTag
{
    NSMutableDictionary* privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* keyPairAttr = [[NSMutableDictionary alloc] init];
    
    NSData* publicTagData = [publicTag dataUsingEncoding:NSUTF8StringEncoding];
    NSData* privateTagData = [privateTag dataUsingEncoding:NSUTF8StringEncoding];
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    
    [keyPairAttr setObject:(id)kSecAttrKeyTypeRSA
                    forKey:(id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithInt:keyBits]
                    forKey:(id)kSecAttrKeySizeInBits];
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES]
                       forKey:(id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTagData
                       forKey:(id)kSecAttrApplicationTag];
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES]
                      forKey:(id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTagData
                      forKey:(id)kSecAttrApplicationTag];
    
    [keyPairAttr setObject:privateKeyAttr
                    forKey:(id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr
                    forKey:(id)kSecPublicKeyAttrs];
    
    OSStatus status = SecKeyGeneratePair((CFDictionaryRef)keyPairAttr, &publicKey, &privateKey);
    
    NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
    
    if(privateKeyAttr) [privateKeyAttr release];
    if(publicKeyAttr) [publicKeyAttr release];
    if(keyPairAttr) [keyPairAttr release];
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
    
    return status == noErr;
}
/*
+ (NSData*)generateRSAPublicKeyWithModulus:(NSData*)modulus exponent:(NSData*)exponent
{
    const uint8_t DEFAULT_EXPONENT[] = {0x01, 0x00, 0x01,};    //default: 65537
    const uint8_t UNSIGNED_FLAG_FOR_BYTE = 0x81;
    const uint8_t UNSIGNED_FLAG_FOR_BYTE2 = 0x82;
    const uint8_t UNSIGNED_FLAG_FOR_BIGNUM = 0x00;
    const uint8_t SEQUENCE_TAG = 0x30;
    const uint8_t INTEGER_TAG = 0x02;
    
    uint8_t* modulusBytes = (uint8_t*)[modulus bytes];
    uint8_t* exponentBytes = (uint8_t*)(exponent == nil ? DEFAULT_EXPONENT : [exponent bytes]);
    
    //(1) calculate lengths
    //- length of modulus
    int lenMod = [modulus length];
    if(modulusBytes[0] >= 0x80)
        lenMod ++;    //place for UNSIGNED_FLAG_FOR_BIGNUM
    int lenModHeader = 2 + (lenMod >= 0x80 ? 1 : 0) + (lenMod >= 0x0100 ? 1 : 0);
    //- length of exponent
    int lenExp = exponent == nil ? sizeof(DEFAULT_EXPONENT) : [exponent length];
    int lenExpHeader = 2;
    //- length of body
    int lenBody = lenModHeader + lenMod + lenExpHeader + lenExp;
    //- length of total
    int lenTotal = 2 + (lenBody >= 0x80 ? 1 : 0) + (lenBody >= 0x0100 ? 1 : 0) + lenBody;
    
    int index = 0;
    uint8_t* byteBuffer = malloc(sizeof(uint8_t) * lenTotal);
    memset(byteBuffer, 0x00, sizeof(uint8_t) * lenTotal);
    
    //(2) fill up byte buffer
    //- sequence tag
    byteBuffer[index ++] = SEQUENCE_TAG;
    //- total length
    if(lenBody >= 0x80)
        byteBuffer[index ++] = (lenBody >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenBody >= 0x0100)
    {
        byteBuffer[index ++] = (uint8_t)(lenBody / 0x0100);
        byteBuffer[index ++] = lenBody % 0x0100;
    }
    else
        byteBuffer[index ++] = lenBody;
    //- integer tag
    byteBuffer[index ++] = INTEGER_TAG;
    //- modulus length
    if(lenMod >= 0x80)
        byteBuffer[index ++] = (lenMod >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenMod >= 0x0100)
    {
        byteBuffer[index ++] = (int)(lenMod / 0x0100);
        byteBuffer[index ++] = lenMod % 0x0100;
    }
    else
        byteBuffer[index ++] = lenMod;
    //- modulus value
    if(modulusBytes[0] >= 0x80)
        byteBuffer[index ++] = UNSIGNED_FLAG_FOR_BIGNUM;
    memcpy(byteBuffer + index, modulusBytes, sizeof(uint8_t) * [modulus length]);
    index += [modulus length];
    //- exponent length
    byteBuffer[index ++] = INTEGER_TAG;
    byteBuffer[index ++] = lenExp;
    //- exponent value
    memcpy(byteBuffer + index, exponentBytes, sizeof(uint8_t) * lenExp);
    index += lenExp;
    
    if(index != lenTotal)
        NSLog(@"lengths mismatch: index = %d, lenTotal = %d", index, lenTotal);
    
    NSMutableData* buffer = [NSMutableData dataWithBytes:byteBuffer length:lenTotal];
    free(byteBuffer);
    
    return buffer;
}
*/

+ (NSData * __nullable)generateRSAPublicKeyWithModulus:(NSData * __nonnull)modulus exponent:(NSData * __nonnull)exponent {
    const uint8_t DEFAULT_EXPONENT[] = {0x01, 0x00, 0x01,}; //default: 65537
    const uint8_t UNSIGNED_FLAG_FOR_BYTE = 0x81;
    const uint8_t UNSIGNED_FLAG_FOR_BYTE2 = 0x82;
    const uint8_t UNSIGNED_FLAG_FOR_BIGNUM = 0x00;
    const uint8_t SEQUENCE_TAG = 0x30;
    const uint8_t INTEGER_TAG = 0x02;
    
    uint8_t* modulusBytes = (uint8_t*)[modulus bytes];
    uint8_t* exponentBytes = (uint8_t*)(exponent == nil ? DEFAULT_EXPONENT : [exponent bytes]);
    
    //(1) calculate lengths
    //- length of modulus
    int lenMod = (int)[modulus length];
    if (modulusBytes[0] >= 0x80)
        lenMod ++;  //place for UNSIGNED_FLAG_FOR_BIGNUM
    int lenModHeader = 2 + (lenMod >= 0x80 ? 1 : 0) + (lenMod >= 0x0100 ? 1 : 0);
    //- length of exponent
    int lenExp = exponent == nil ? sizeof(DEFAULT_EXPONENT) : (int)[exponent length];
    int lenExpHeader = 2;
    //- length of body
    int lenBody = lenModHeader + lenMod + lenExpHeader + lenExp;
    //- length of total
    int lenTotal = 2 + (lenBody >= 0x80 ? 1 : 0) + (lenBody >= 0x0100 ? 1 : 0) + lenBody;
    
    int index = 0;
    uint8_t* byteBuffer = malloc(sizeof(uint8_t) * lenTotal);
    memset(byteBuffer, 0x00, sizeof(uint8_t) * lenTotal);
    
    //(2) fill up byte buffer
    //- sequence tag
    byteBuffer[index ++] = SEQUENCE_TAG;
    //- total length
    if(lenBody >= 0x80)
        byteBuffer[index ++] = (lenBody >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenBody >= 0x0100) {
        byteBuffer[index ++] = (uint8_t)(lenBody / 0x0100);
        byteBuffer[index ++] = lenBody % 0x0100;
    }
    else
        byteBuffer[index ++] = lenBody;
    //- integer tag
    byteBuffer[index ++] = INTEGER_TAG;
    //- modulus length
    if (lenMod >= 0x80)
        byteBuffer[index ++] = (lenMod >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if (lenMod >= 0x0100) {
        byteBuffer[index ++] = (int)(lenMod / 0x0100);
        byteBuffer[index ++] = lenMod % 0x0100;
    }
    else
        byteBuffer[index ++] = lenMod;
    //- modulus value
    if (modulusBytes[0] >= 0x80)
        byteBuffer[index ++] = UNSIGNED_FLAG_FOR_BIGNUM;
    memcpy(byteBuffer + index, modulusBytes, sizeof(uint8_t) * [modulus length]);
    index += [modulus length];
    //- exponent length
    byteBuffer[index ++] = INTEGER_TAG;
    byteBuffer[index ++] = lenExp;
    //- exponent value
    memcpy(byteBuffer + index, exponentBytes, sizeof(uint8_t) * lenExp);
    index += lenExp;
    
    if (index != lenTotal)
        NSLog(@"lengths mismatch: index = %d, lenTotal = %d", index, lenTotal);
    
    NSMutableData* buffer = [NSMutableData dataWithBytes:byteBuffer length:lenTotal];
    free(byteBuffer);
    
    return buffer;
}



+ (BOOL)saveRSAPublicKey:(NSData*)publicKey appTag:(NSString*)appTag overwrite:(BOOL)overwrite
{
    CFDataRef ref;
    OSStatus status = SecItemAdd((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                   (id)kSecClassKey, kSecClass,
                                                   (id)kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                   (id)kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                   kCFBooleanTrue, kSecAttrIsPermanent,
                                                   [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
                                                   publicKey, kSecValueData,
                                                   kCFBooleanTrue, kSecReturnPersistentRef,
                                                   nil],
                                 (CFTypeRef *)&ref);
    
    NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
    
    if(status == noErr)
        return YES;
    else if(status == errSecDuplicateItem && overwrite == YES)
        return [CryptoUtil updateRSAPublicKey:publicKey appTag:appTag];
    
    return NO;
}

+ (BOOL)updateRSAPublicKey:(NSData*)publicKey appTag:(NSString*)appTag
{
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                            (id)kSecClassKey, kSecClass,
                                                            kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                            kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                            [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
                                                            nil],
                                          NULL);    //don't need public key ref
    
    NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
    
    if(status == noErr)
    {
        status = SecItemUpdate((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                 (id)kSecClassKey, kSecClass,
                                                 kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                 kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                 [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
                                                 nil],
                               (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                 publicKey, kSecValueData,
                                                 nil]);
        
        NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
        
        return status == noErr;
    }
    return NO;
}

+ (BOOL)deleteRSAPublicKeyWithAppTag:(NSString*)appTag
{
    OSStatus status = SecItemDelete((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                      (id)kSecClassKey, kSecClass,
                                                      kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                      kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                      [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
                                                      nil]);
    
    NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
    
    return status == noErr;
}

/*
 * returned value(SecKeyRef) should be released with CFRelease() function after use.
 *
 */
+ (SecKeyRef)loadRSAPublicKeyRefWithAppTag:(NSString*)appTag
{
    SecKeyRef publicKeyRef;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:
                                                            (id)kSecClassKey, kSecClass,
                                                            kSecAttrKeyTypeRSA, kSecAttrKeyType,
                                                            kSecAttrKeyClassPublic, kSecAttrKeyClass,
                                                            [appTag dataUsingEncoding:NSUTF8StringEncoding], kSecAttrApplicationTag,
                                                            kCFBooleanTrue, kSecReturnRef,
                                                            nil],
                                          (CFTypeRef*)&publicKeyRef);
    
    NSLog(@"result = %@", [KeychainUtil fetchStatus:status]);
    
    if(status == noErr)
        return publicKeyRef;
    else
        return NULL;
}

/**
 * encrypt with RSA public key
 *
 * padding = kSecPaddingPKCS1 / kSecPaddingNone
 *
 */
+ (NSData*)encryptString:(NSString*)original RSAPublicKey:(SecKeyRef)publicKey padding:(SecPadding)padding
{
    @try
    {
        size_t encryptedLength = SecKeyGetBlockSize(publicKey);
        uint8_t encrypted[encryptedLength];
        
        const char* cStringValue = [original UTF8String];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        padding,
                                        (const uint8_t*)cStringValue,
                                        strlen(cStringValue),
                                        encrypted,
                                        &encryptedLength);
        if(status == noErr)
        {
            NSData* encryptedData = [[NSData alloc] initWithBytes:(const void*)encrypted length:encryptedLength];
            return [encryptedData autorelease];
        }
        else
            return nil;
    }
    @catch (NSException * e)
    {
        //do nothing
        NSLog(@"exception: %@", [e reason]);
    }
    return nil;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned int len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (SecKeyRef)RSAPublicKeyRefFromBase64String:(NSString *)key withTag:(NSString *)tag
{
    NSString *s_key = [NSString string];
    NSArray  *a_key = [key componentsSeparatedByString:@"\n"];
    BOOL     f_key  = FALSE;
    
    for (NSString *a_line in a_key) {
        if ([a_line isEqualToString:@"-----BEGIN PUBLIC KEY-----"]) {
            f_key = TRUE;
        }
        else if ([a_line isEqualToString:@"-----END PUBLIC KEY-----"]) {
            f_key = FALSE;
        }
        else if (f_key) {
            s_key = [s_key stringByAppendingString:a_line];
        }
    }
    if (s_key.length == 0) return(FALSE);
    
    // This will be base64 encoded, decode it.
    NSData *d_key = [NSData dataWithBase64EncodedString:s_key];
    d_key = [self stripPublicKeyHeader:d_key];
    if (d_key == nil) return(FALSE);
    
    
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(id) kSecClassKey forKey:(id)kSecClass];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(id)kSecAttrApplicationTag];
    SecItemDelete((CFDictionaryRef)publicKey);
    
    CFTypeRef persistKey = nil;
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:d_key forKey:(id)kSecValueData];
    [publicKey setObject:(id) kSecAttrKeyClassPublic forKey:(id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)
     kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) CFRelease(persistKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem)) {
        [publicKey release];
        return(FALSE);
    }
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    
    [publicKey removeObjectForKey:(id)kSecValueData];
    [publicKey removeObjectForKey:(id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)kSecReturnRef
     ];
    [publicKey setObject:(id) kSecAttrKeyTypeRSA forKey:(id)kSecAttrKeyType];
    secStatus = SecItemCopyMatching((CFDictionaryRef)publicKey,
                                    (CFTypeRef *)&keyRef);
    
    [publicKey release];
    
    if (keyRef == nil)
        return(FALSE);
    else
        return keyRef;
}



@end
