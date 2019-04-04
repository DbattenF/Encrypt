//
//  Logging.swift
//  Encrypt
//
//  Created by Sebastian FIorentino on 03/04/2019.
//  Copyright © 2019 Sebastian FIorentino. All rights reserved.
//

import Foundation

public class Logging{
    public init(){
    }
    public func testFunc(){
        let encryp = RSAEncryptorService.encrypt(modulus: "hola", message: "Chau")
        print(encryp)
        print(AESEncryptorService.decrypt(encryp, ivUser: "IV", shaUser: "SHA"))
        print(StringEncryption().encrypt(NSData() as Data, key: "Chau", iv: "Hola"))
    }
}
