//
//  kDynamoController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 10/3/17.
//  Copyright © 2017 MagTek. All rights reserved.
//

//import Cocoa
import UIKit
class kDynamoController: eDynamoController {
    var firstLED:UIView!;
    var secondLED:UIView!;
    var thirdLED:UIView!;
    var fourthLED:UIView!;
    var idleTimer:Timer!;
    
    override func viewDidLoad() {
        self.shouldNotOffset = true

        super.viewDidLoad();
        self.title = "Lightning EMV";
        self.lib = MTSCRA();
        
        let xOffset = (self.navigationController?.navigationBar.frame.size.height ?? 0) + (self.tabBarController?.tabBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height;
        
           self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Data", style: .plain, target: self, action: #selector(MTDataViewerViewController.clearData));
        self.lib.delegate = self;
        self.txtData?.frame =  CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 270 - xOffset);
        self.lib.setDeviceType(UInt32(MAGTEKKDYNAMO));
        self.lib.setDeviceProtocolString("com.magtek.idynamo")
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        self.btnConnect?.removeTarget(nil, action: nil, for: UIControl.Event.touchUpInside);
        
        self.btnConnect?.addTarget(self, action: #selector(kDynamoController.connect), for: .touchUpInside);
        addLED();
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
       // self.lib.openDevice()
    }
    
    @objc func appWillResignActive(_ note: Notification?) {
        lib.closeDevice()
    }
    @objc func appDidBecomeActive(_ note: Notification?) {
        //lib.openDevice()
    }
    
    func addLED()
    {
        
        var xOffset : CGFloat = 0;
        
        if(self.isX())
        {
            xOffset = 5
        }
        
        firstLED = UIView(frame: CGRect(x: (self.btnStartEMV?.frame.origin.x)!, y: (self.btnStartEMV?.frame.origin.y)! - 60 - xOffset, width: (self.btnStartEMV?.frame.size.width)!, height: (self.btnStartEMV?.frame.size.height)!));
        firstLED.backgroundColor = UIColor.gray;
        self.view.addSubview(firstLED);
        
        secondLED = UIView(frame: CGRect(x: (self.btnCancel?.frame.origin.x)!, y: (self.btnCancel?.frame.origin.y)! - 60 - xOffset, width: (self.btnCancel?.frame.size.width)!, height: (self.btnCancel?.frame.size.height)!));
        secondLED.backgroundColor = UIColor.gray;
        self.view.addSubview(secondLED);
        
        thirdLED = UIView(frame: CGRect(x: (self.btnReset?.frame.origin.x)!, y: (self.btnReset?.frame.origin.y)! - 60 - xOffset, width: (self.btnReset?.frame.size.width)!, height: (self.btnReset?.frame.size.height)!));
        thirdLED.backgroundColor = UIColor.gray;
        self.view.addSubview(thirdLED);
        
        fourthLED = UIView(frame: CGRect(x: (self.btnOptions?.frame.origin.x)!, y: (self.btnOptions?.frame.origin.y)! - 60 - xOffset, width: (self.btnOptions?.frame.size.width)!, height: (self.btnOptions?.frame.size.height)!));
        fourthLED.backgroundColor = UIColor.gray;
        self.view.addSubview(fourthLED);
        
    }
    func setLEDState(state:Int)
    {
        switch state
        {
            case 0:
                DispatchQueue.main.async {
                    self.firstLED.backgroundColor = .gray;
                    self.secondLED.backgroundColor = .gray;
                    self.thirdLED.backgroundColor = .gray;
                    self.fourthLED.backgroundColor = .gray;
                    self.idleTimer.invalidate();
                    self.idleTimer = nil;
            }
                break;
        case 1:
            firstLED.backgroundColor = .green;
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.firstLED.backgroundColor = .gray;
                
            })
            idleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(idleTimer1), userInfo: nil, repeats: true)
            break;
        case 2:
            DispatchQueue.main.async {
                self.firstLED.backgroundColor = .green;
            };
            break;
        case 3:
            var offsetTime = 0.0;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.firstLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.secondLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.thirdLED.backgroundColor = .green;
            });
            offsetTime += 0.25;
            DispatchQueue.main.asyncAfter(deadline: .now() + offsetTime + 0.25, execute: {
                self.fourthLED.backgroundColor = .green;
            });
           // offsetTime += 0.25;
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.setLEDState(state: 0);
            });
            
            break;
        default:
            break;
        }
    }
    
    @objc func idleTimer1() {
        DispatchQueue.main.async(execute: {
            if self.firstLED.backgroundColor == UIColor.gray {
                
                self.firstLED.backgroundColor = UIColor.green
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    self.firstLED.backgroundColor = UIColor.gray
                })
            }
        })
    }
    
    func hideLED(hidden:Bool)
    {
        firstLED.isHidden = hidden;
        secondLED.isHidden = hidden;
        thirdLED.isHidden = hidden;
        fourthLED.isHidden = hidden;
    }
    
    override func startEMV() {
        super.startEMV();
        hideLED(hidden: false);
    }
   // override func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: AnyObject!) {
   override func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
     
        super.onDeviceConnectionDidChange(deviceType, connected: connected, instance: instance);
        
        
//        if(deviceType == MAGTEKKDYNAMO)
//        {
//            if(connected)
//            {
//                setLEDState(state: 1);
//                self.lib.sendcommand(withLength: "480102")
//
//            }
//            else
//            {
//                setLEDState(state: 0);
//            }
//        }
    }

    override func onTransactionResult(_ data: Data!) {
        super.onTransactionResult(data);
        setLEDState(state: 0);
        setLEDState(state: 1);
        
    }
    override func onTransactionStatus(_ data: Data!) {
        super.onTransactionResult(data);
        
        
        let dataBytes = data.withUnsafeBytes {
            Array(UnsafeBufferPointer<UInt32>(start: $0, count: data.count/MemoryLayout<UInt32>.size))
        }
        
        if(dataBytes[0] == 0x04 && dataBytes[2] == 0x01)
        {
            self.setLEDState(state: 0);
            self.setLEDState(state: 2);
            
        }
        else if (dataBytes[0] == 0x09 && dataBytes[2] == 0x3c)
        {
            self.setLEDState(state: 0);
            self.setLEDState(state: 3);
        }
    }
    
    
    
    
    @objc override func connect() {
        super.connect();
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var xOffset : CGFloat = 0;
        var yOffset : CGFloat = 0;
        
        if(self.isX())
        {
            xOffset = 10
            yOffset = 5
        }
        
        let btnWidth: CGFloat = size.width / 4
        self.btnStartEMV?.frame = CGRect(x: 5, y: size.height - 98 - xOffset, width: btnWidth - 7, height: 40);
        self.btnCancel?.frame = CGRect(x: btnWidth, y: size.height - 98 - xOffset, width: btnWidth - 2, height: 40);
        self.btnReset?.frame = CGRect(x: (btnWidth * 2), y: size.height - 98 - xOffset, width: btnWidth - 2, height: 40)
        self.btnOptions?.frame = CGRect(x: (btnWidth * 3), y: size.height - 98 - xOffset, width: btnWidth - 2, height: 40)
        self.btnConnect?.frame = CGRect(x: 0, y: size.height - 98 - 65 + 120 - yOffset, width: size.width, height: 50)
        self.txtData?.frame = CGRect(x: 5, y: 60, width: size.width - 10, height: size.height - 370 - xOffset + 120)
        self.firstLED?.frame = CGRect(x: self.btnStartEMV!.frame.origin.x, y: (self.btnStartEMV?.frame.origin.y)! - 60 - yOffset, width: (self.btnStartEMV?.frame.size.width)!, height: (self.btnStartEMV?.frame.size.height)!)
        self.secondLED?.frame  = CGRect(x: self.btnCancel!.frame.origin.x, y: (self.btnCancel?.frame.origin.y)! - 60 - yOffset, width: (self.btnCancel?.frame.size.width)!, height: (self.btnCancel?.frame.size.height)!)
        self.thirdLED?.frame  = CGRect(x: self.btnReset!.frame.origin.x, y: (self.btnReset?.frame.origin.y)! - 60 - yOffset, width: (self.btnReset?.frame.size.width)!, height: (self.btnReset?.frame.size.height)!)
        self.fourthLED?.frame  = CGRect(x: self.btnOptions!.frame.origin.x, y: (self.btnOptions?.frame.origin.y)! - 60 - yOffset, width: (self.btnOptions?.frame.size.width)!, height: (self.btnOptions?.frame.size.height)!)
        self.txtCommand?.frame = CGRect(x: 5 , y: 9, width: size.width - 170, height: 40)
        self.btnSendCommand?.frame = CGRect(x: (self.txtCommand?.frame.origin.x)! + size.width - 170 + 5 , y: 9, width: 75, height: 40)
        self.btnGetSN?.frame = CGRect(x: self.btnSendCommand!.frame.origin.x + 75 + 5 , y: 9, width: 75, height: 40)
    }
}
