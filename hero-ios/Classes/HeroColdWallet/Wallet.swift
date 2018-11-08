//
//  Wallet.swift
//  Achilles-iOS
//
//  Created by 李潇 on 2018/11/1.
//  Copyright © 2018 daniel. All rights reserved.
//

import Foundation

class Wallet {
    static let shared = Wallet()
    static let localKey = "HER-Wallets"
    
    var accounts = [Account]()
    
    func add(_ account: Account) {
        accounts.append(account)
        self.save()
    }
    
    func remove(_ id: String) {
        if let index = accounts.firstIndex(where: {
            $0.id == id
        }) {
            let acc = accounts[index]
            acc.destory()
            accounts.remove(at: index)
            save()
        }
    }
    
    func save() {
        if accounts.count > 0 {
            let ids = accounts.map{
                $0.id
            }
            print(ids)
            UserDefaults.standard.setValue(ids, forKey: Wallet.localKey)
            UserDefaults.standard.synchronize()
            
            for acc in accounts {
                acc.save()
            }
        }
    }
    
    func load() {
        if let ids = UserDefaults.standard.array(forKey: Wallet.localKey) as? Array<String> {
            for id in ids {
                if let acc = Account.load(id: id) {
                    self.accounts.append(acc)
                }
            }
        }
    }
}
