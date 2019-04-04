//
//  EncryptorService.swift
//  webcampusdocentes
//
//  Created by Sebastia FIorentino on 02/01/2019.
//  Copyright © 2019 Sebastian FIorentino. All rights reserved.
//

import Foundation
import UIKit
import Security

let exponentString = "AQAB"

class RSAEncryptorService {

    static func encrypt(modulus: String, message: String) -> String {
        let modData = Data(base64Encoded: modulus)
        let expData = Data(base64Encoded: exponentString)

        let datakey = GetPubKey.generateRSAPublicKey(withModulus: modData!, exponent: expData!)

        let keyDict: [NSObject: NSObject] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: 2048),
            kSecReturnPersistentRef: true as NSObject
        ]

        let publickeysi = SecKeyCreateWithData(datakey! as CFData, keyDict as CFDictionary, nil)

        //Encrypt a string with the public key
        let blockSize = SecKeyGetBlockSize(publickeysi!)
        var messageEncrypted = [UInt8](repeating: 0, count: blockSize)
        var messageEncryptedSize = blockSize

        var status: OSStatus!

        status = SecKeyEncrypt(publickeysi!, SecPadding.PKCS1, message, message.count, &messageEncrypted, &messageEncryptedSize)

        if status != noErr {
            print("Encryption Error!")
        }

        let data = NSData(bytes: messageEncrypted, length: messageEncryptedSize)
        let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        return base64String
    }

    static func prepareEncryptedMessage(message: String, publickKey: String) -> String {
        let modulusString = publickKey//User.getInstance().getUserData(key: "publicKey")
        return RSAEncryptorService.encrypt(modulus: modulusString, message: message)
    }

}
