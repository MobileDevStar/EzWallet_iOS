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

    var webView: WKWebView!
    
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
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let body = message.body as! String
        let data = body.components(separatedBy: ",")
        
        let type = data[0]
        let saveType = "save"
        let loadType = "load"
        if(type.caseInsensitiveCompare(saveType) == .orderedSame){
            let key = data[1]
            let value = data[2]
            
            NSLog("*************key value********")
            NSLog(key)
            NSLog(value)
            
            UserDefaults.standard.set(value, forKey: key)
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


