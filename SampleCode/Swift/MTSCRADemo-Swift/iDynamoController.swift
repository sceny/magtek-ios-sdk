//
//  iDynamoController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit

class iDynamoController: MTDataViewerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "iDynamo";
        
        //[self.btnConnect addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
        
        self.lib = MTSCRA();
        self.lib.delegate = self;
        
        self.lib.setDeviceType(UInt32(MAGTEKIDYNAMO));
        self.lib.setDeviceProtocolString("com.magtek.idynamo");
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

       //self.lib.openDevice()
        
    }
    @objc func appWillResignActive(_ note: Notification?) {

    }
   @objc func appDidBecomeActive(_ note: Notification?) {

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
        super.onDeviceConnectionDidChange(deviceType, connected: connected, instance: instance as AnyObject?)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("**************Before load Size: \(self.view.frame.size.height)")
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (nil) in
            print("*********After Load Size: \(self.view.frame.size.height)")
        }
        self.view.frame.size.height -= 20
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("*********After2222222 Load Size: \(self.view.frame.size.height)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
