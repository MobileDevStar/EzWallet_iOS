//
//  ViewController.swift
//  Inspec EZ Safety Wallet
//
//  Created by John Gregory on 2019-06-27.
//  Copyright © 2019 Inspec Health Solutions. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    var SAVE_PASSWORD_KEY: String = "save_password"
    var USERNAME_KEY: String = "username"
    var PASSWORD_KEY: String = "password"
    
    var SAVE_PASSWORD_STATE_NOTNOW: Int = 0
    var SAVE_PASSWORD_STATE_NEVER: Int = 1
    var SAVE_PASSWORD_STATE_SAVED: Int = 2

    var webView: WKWebView!
    var m_strCurUserName: String!
    var m_strCurPassword: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  Load the Web View into the Object
        let theConfiguration = WKWebViewConfiguration()
        let thisPref = WKPreferences()
        
        thisPref.javaScriptCanOpenWindowsAutomatically = true
        thisPref.javaScriptEnabled = true
        
        theConfiguration.preferences = thisPref
        theConfiguration.userContentController.add(self, name: "EzWalletApi")
        
        webView = WKWebView(frame: view.frame, configuration: theConfiguration)
        //webView.load(URLRequest(url: URL(string: "https://111.datatrium.com/fmi/webd/ezwallet")!))
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.uiDelegate = self
        webView.load(URLRequest(url: URL(string: "https://111.datatrium.com")!))
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    func checkState() {
        let state: Int = UserDefaults.standard.integer(forKey: SAVE_PASSWORD_KEY)
        
        if state == SAVE_PASSWORD_STATE_NOTNOW {
            // create the alert
            let alert = UIAlertController(title: "Save Password", message: "Would you like to save this password for the app?", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
                self.saveState(value: self.SAVE_PASSWORD_STATE_SAVED)
                self.saveUserInfo()
            }))
            alert.addAction(UIAlertAction(title: "Never", style: UIAlertAction.Style.destructive, handler: { action in
                self.saveState(value: self.SAVE_PASSWORD_STATE_NEVER)
            }))
            alert.addAction(UIAlertAction(title: "Not Now", style: UIAlertAction.Style.cancel, handler: { action in
                self.saveState(value: self.SAVE_PASSWORD_STATE_NOTNOW)
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveState(value: Int) {
        UserDefaults.standard.set(value, forKey: SAVE_PASSWORD_KEY)
    }
    
    func saveUserInfo() {
        UserDefaults.standard.set(m_strCurUserName, forKey: USERNAME_KEY)
        UserDefaults.standard.set(m_strCurPassword, forKey: PASSWORD_KEY)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let body = message.body as! String
        let data = body.components(separatedBy: ",")
        
        let type = data[0]
        let saveType = "save"
        let loadType = "load"
        if(type.caseInsensitiveCompare(saveType) == .orderedSame){
            let username = data[1]
            let password = data[2]
            
            m_strCurUserName = username
            m_strCurPassword = password
            
            
            NSLog("*************key value********")
            NSLog(username)
            NSLog(password)
            
            checkState()
            //UserDefaults.standard.set(value, forKey: key)
        } else if (type.caseInsensitiveCompare(loadType) == .orderedSame) {
            let key1 = data[1]
            let key2 = data[2]
            
            let username: String = UserDefaults.standard.string(forKey: key1) ?? ""
            let password: String = UserDefaults.standard.string(forKey: key2) ?? ""
            
            webView.evaluateJavaScript("setSavedUserIOS('\(username)', '\(password)');", completionHandler: { (innerHTML, error ) in
              // NSLog(error as! String)
            })            
        }
    }
}


