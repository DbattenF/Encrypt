//
//  AESEncryptorService.swift
//  webcampusdocentes
//
//  Created by Sebastia FIorentino on 07/01/2019.
//  Copyright © 2019 Sebastian FIorentino. All rights reserved.
//

import Foundation

class AESEncryptorService {

    static func decrypt(_ cipherBase64: String, ivUser: String, shaUser: String) -> String {
        
        let cryptLib = StringEncryption()
        let iv = ivUser//User.getInstance().getUserData(key: "iv")
        let key = shaUser//User.getInstance().getUserData(key: "sha")
        
        let sha =  cryptLib.sha256(key, length: 32)

        let cipherData = Data.init(base64Encoded: cipherBase64)
        //cryptLib.decrypt devuelve un optional, asi que uso un unwrappred en el return para que no devuelva un optional
        let desencriptado = cryptLib.decrypt(cipherData, key: sha, iv: iv)
        let output  = String.init(data: desencriptado!, encoding: String.Encoding.utf8)
        return output ?? ""
    }

}
