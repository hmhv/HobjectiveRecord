//
//  ViewController.swift
//  HobjectiveRecordDemo-Swift
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit
import Social
import Accounts

class ViewController: UIViewController {

    var accountStore = ACAccountStore()
    
    var twitterAccount: ACAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, error) -> Void in
            if granted {
                let twitterAccounts = self.accountStore.accountsWithAccountType(twitterAccountType)
                self.twitterAccount = twitterAccounts.first as? ACAccount
            }
            else {
                println("\(error)")
            }
        }
    }

    @IBAction func removeAllData() {
        var moc = NSManagedObjectContext.defaultContext()
        
        moc.performBlock { () -> Void in
            println("Before Delete \(Tweet.count()) tweets of \(User.count()) users")
            
            Tweet.deleteAll()
            User.deleteAll()
            moc.save()

            println("After Delete \(Tweet.count()) tweets of \(User.count()) users")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "TweetSegue" {
            var vc = segue.destinationViewController as! TweetViewController
            vc.twitterAccount = self.twitterAccount
        }
        else {
            var vc = segue.destinationViewController as! TweetViewController
            vc.twitterAccount = self.twitterAccount
            vc.use3Layer = true
        }
    }
}

