//
//  Account.swift
//  Achilles-iOS
//
//  Created by 李潇 on 2018/11/1.
//  Copyright © 2018 daniel. All rights reserved.
//

import Foundation
import Web3swift

let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

let ksKey = "keystore"
let nameKey = "name"
let logoKey = "logo"
let idKey = "id"
let passwdKey = "password"

class Account: NSObject, NSCoding {
    var ks: EthereumKeystoreV3?
    var name: String
    var logo: String
    var id: String
    var address: String {
        get {
            return (ks?.addresses?.first?.address)!
        }
    }
    var password: String  // just save to use fingerpring
    
    init(name: String, logo: String, ks: EthereumKeystoreV3?, password: String) {
        self.name = name
        self.logo = logo
        self.ks = ks
        self.id = UUID().uuidString
        self.password = password
    }
    
    func save() {
        let obj = NSKeyedArchiver.archivedData(withRootObject: self)
//            Alert.showError("账户保存失败")
        
        UserDefaults.standard.set(obj, forKey: id)
        UserDefaults.standard.synchronize()
        
        let keydata = try! JSONEncoder().encode(ks!.keystoreParams)
        let path = userDir + "/" + id + ".json"
        FileManager.default.createFile(atPath: path, contents: keydata, attributes: nil)
    }
    
    static func load(id: String) -> Account? {
        let obj = UserDefaults.standard.data(forKey: id)
        guard let acc = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(obj!) as? Account else {
//            Alert.showError("账户读取失败")
            return nil
        }
        
        let keydata = FileManager.default.contents(atPath: userDir + "/" + id + ".json")
        let ks = EthereumKeystoreV3(keydata!)
        
        acc?.ks = ks!
        return acc
    }
    
    func destory() {
        UserDefaults.standard.removeObject(forKey: id)
        UserDefaults.standard.synchronize()
        
        let path = userDir + "/" + id + ".json"
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
//            Alert.showError("删除keystore文件出错")
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: idKey)
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(logo, forKey: logoKey)
        aCoder.encode(password, forKey: passwdKey)
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: nameKey) as? String ?? ""
        self.logo = decoder.decodeObject(forKey: logoKey) as? String ?? ""
        self.id = decoder.decodeObject(forKey: logoKey) as? String ?? ""
        self.password = decoder.decodeObject(forKey: passwdKey) as? String ?? ""
    }
}

extension Account {
    func sign(_ transaction:inout EthereumTransaction, password: String) throws {
        do {
            try Web3Signer.signTX(transaction: &transaction, keystore: self.ks!, account: self.ks!.getAddress()!, password: password)
            print(transaction)
        } catch {
            if error is AbstractKeystoreError {
                throw Web3Error.keystoreError(err: error as! AbstractKeystoreError)
            }
            throw Web3Error.generalError(err: error)
        }
    }
}
