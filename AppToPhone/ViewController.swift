//
//  ViewController.swift
//  AppToPhone
//
//  Created by Paul Ardeleanu on 02/06/2020.
//  Copyright © 2020 Nexmo. All rights reserved.
//

import UIKit
import NexmoClient

class ViewController: UIViewController {

    var connectionStatusLabel = UILabel()
    var callButton = UIButton(type: .roundedRect)
    let client = NXMClient.shared
    var call: NXMCall?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        connectionStatusLabel.text = "Unknown"
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectionStatusLabel)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[label(20)]", options: [], metrics: nil, views: ["label" : connectionStatusLabel]))
        
        callButton.setTitle("Call", for: .normal)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(callButton)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[button]-20-|", options: [], metrics: nil, views: ["button": callButton]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label]-40-[button(40)]", options: [], metrics: nil, views: ["label" : connectionStatusLabel, "button": callButton]))
        callButton.alpha = 0
        callButton.addTarget(self, action: #selector(callButtonPressed(_:)), for: .touchUpInside)
        
        client.setDelegate(self)
        client.login(withAuthToken: "ALICE_JWT")
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        if call == nil {
            placeCall()
        } else {
            endCall()
        }
    }
    func placeCall() {
        callButton.setTitle("End Call", for: .normal)
        client.call("PHONE_NUMBER", callHandler: .server) {  [weak self] (error, call) in
            if let error = error {
                self?.connectionStatusLabel.text = error.localizedDescription
                self?.callButton.setTitle("Call", for: .normal)
            }
            self?.call = call
        }
    }

    func endCall() {
        call?.hangup()
        call = nil
        callButton.setTitle("Call", for: .normal)
    }

}


extension ViewController: NXMClientDelegate {
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        print("✆  ‼️ connection error: \(error.localizedDescription)")
        callButton.alpha = 0
        connectionStatusLabel.text = error.localizedDescription
    }
    
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus,
                reason: NXMConnectionStatusReason) {
        callButton.alpha = 0
        switch status {
        case .connected:
            connectionStatusLabel.text = "Connected"
            callButton.alpha = 1
        case .disconnected:
            connectionStatusLabel.text = "Disconnected"
        case .connecting:
            connectionStatusLabel.text = "Connecting"
        @unknown default:
            connectionStatusLabel.text = "Unknown"
        }
    }
    
}
