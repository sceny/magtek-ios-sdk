//
//  MTDataViewerViewController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit
import MediaPlayer

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
typealias cmdCompBlock = (String?) -> Void


class MTDataViewerViewController: UIViewController, UITextFieldDelegate,MTSCRAEventDelegate{
    var btnConnect:UIButton?;
    var btnSendCommand:UIButton?;
    var txtData: UITextView?;
    var txtDebugConsole: UITextView?;
    var txtCommand:UITextField?;
    var lib: MTSCRA!;
    var cmdCompletion: cmdCompBlock?
    var btnGetSN : UIButton?
    var devicePaired : Bool?
    let dispatchGroup = DispatchGroup()
    var showDebug: Bool = false;
    var commandResult = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI();
        // Do any additional setup after loading the view.
    }
    func setUpUI()
    {
        devicePaired = true
        
        let yOffset = (self.navigationController?.navigationBar.frame.size.height ?? 0) + (self.tabBarController?.tabBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Data", style: .plain, target: self, action: #selector(MTDataViewerViewController.clearData));
        
        btnConnect = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 65 - yOffset, width: self.view.frame.size.width, height: 50));
        btnConnect?.setTitle("Connect", for: UIControl.State());
        btnConnect?.backgroundColor = UIColor(hex: 0x3465AA);
        btnConnect?.addTarget(self, action: #selector(MTDataViewerViewController.connect), for: .touchUpInside);
        
        txtData = UITextView(frame: CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 140 - yOffset));
        txtData?.backgroundColor = UIColor(hex: 0x667788);
        txtData?.textColor = UIColor.white;
        txtData?.isEditable = false;
        
        
        txtDebugConsole = UITextView(frame: CGRect(x: 5, y: txtData!.frame.size.height + 60 + 10, width: self.view.frame.size.width - 10 , height: self.view.frame.size.height / 2 - 20 - yOffset));
        txtDebugConsole?.backgroundColor = UIColor(hex: 0x8395a7);
        txtDebugConsole?.textColor = UIColor.white;
        txtDebugConsole?.isEditable = false;
        txtDebugConsole?.isHidden = true;
        
        txtCommand = UITextField(frame: CGRect(x: 5 , y: 9, width: self.view.frame.size.width - 170, height: 40));
        txtCommand?.delegate = self;
        txtCommand?.backgroundColor = UIColor(hex: 0xdddddd);
        txtCommand?.placeholder = "Send Command";
        
        btnSendCommand = UIButton(frame: CGRect(x: (txtCommand?.frame.origin.x)! + (txtCommand?.frame.size.width)! + 5 , y: 9, width: 75, height: 40));
        btnSendCommand?.setTitle("Send", for: UIControl.State());
        btnSendCommand?.addTarget(self, action: #selector(MTDataViewerViewController.sendCommandMessage), for: .touchUpInside);
        btnSendCommand?.backgroundColor = UIColor(hex: 0x3465AA);
        
        btnGetSN = UIButton(frame: CGRect(x: (btnSendCommand?.frame.origin.x)! + (btnSendCommand?.frame.size.width)! + 5 , y: 9, width: 75, height: 40));
        btnGetSN?.setTitle("Get SN", for: UIControl.State());
        btnGetSN?.addTarget(self, action: #selector(getSerialNumber), for: .touchUpInside);
        btnGetSN?.backgroundColor = UIColor(hex: 0x3465AA);
        
        
        self.view.addSubview(txtCommand!);
        self.view.addSubview(txtData!);
        self.view.addSubview(txtDebugConsole!);
        self.view.addSubview(btnSendCommand!);
        self.view.addSubview(btnGetSN!);
        self.view.addSubview(btnConnect!);
        
        
    }
    
    @objc func turnMSROn() {
        //var rs = [UInt8](repeating:0x00 , count: 3)
        let rsData = sendCommandSync("580101")!
        self.setText(text: "Turning on MSR with result \(rsData)");
        
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    @objc func sendCommandMessage()
    {
        if(txtCommand!.text?.count > 0)
        {
            let rs = lib.sendcommand(withLength: txtCommand?.text);
            guard rs == 0 else {
                self.setText(text: "Send command failed: \(rs)")
                return;
            }
        }
    }
    
    @objc func connect()
    {
        if(!self.lib.isDeviceOpened())
        {
            setText(text: "Connecting")
            self.lib.openDevice();
        }
        else
        {
            self.lib.closeDevice();
            
        }
        
        if self.lib.getDeviceType() == MAGTEKAUDIOREADER
        {
            let musicPlayer : MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer
            MPVolumeView.setVolume(1.0)
            
        }
        
        
        
    }
    @objc func getSerialNumber()
    {
        // DispatchQueue.main.async {
        self.setText(text: "Device Serial Number: \(self.lib.getDeviceSerial() ?? "")\r")
        //}
    }
    
    private func cardSwipeDidStart(_ instance: AnyObject!) {
        DispatchQueue.main.async
            {
                self.txtData!.text = "Transfer started...";
        }
    }
    
    func cardSwipeDidGetTransError() {
        DispatchQueue.main.async
            {
                self.txtData!.text = "Transfer error...";
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if self.lib != nil
        {
            DispatchQueue.main.async(execute: {
                if self.lib.isDeviceOpened() {
                    if self.lib.isDeviceConnected() {
                        
                        self.btnConnect!.setTitle("Disconnect", for: .normal)
                        self.btnConnect!.backgroundColor = UIColor(hex:0xcc3333)
                    } else {
                        
                        
                        self.btnConnect!.setTitle("Connect", for: .normal)
                        self.btnConnect!.backgroundColor = UIColor(hex:0x3465aa)
                    }
                } else {
                    
                    
                    self.btnConnect!.setTitle("Connect", for: .normal)
                    
                    self.btnConnect!.backgroundColor = UIColor(hex:0x3465aa)
                }
                
            })
        }
    }
    
    public func setText(text:String)
    {
        DispatchQueue.main.async {
           // self.txtData!.text = self.txtData!.text + "\r\(text)"
            self.txtData?.text.append("\r\(text)")
            self.scrollTextView(toBottom: self.txtData)
        }
    }
    public func setDebugText(text:String)
    {
        if(self.showDebug)
        {
        DispatchQueue.main.async {
            
            self.txtDebugConsole!.text = self.txtDebugConsole!.text + "\r\(text)"
            self.scrollTextView(toBottom: self.txtDebugConsole)
        }
        }
    }
    func onDisplayMessageRequest(_ data: Data!) {
    }
    func onEMVCommandResult(_ data: Data!) {
        
    }
    func onUserSelectionRequest(_ data: Data!) {
        
    }
    func onARQCReceived(_ data: Data!) {
        
    }
    func onTransactionStatus(_ data: Data!) {
        
    }
    func buildCommand(forAudioTLV commandIn: String?) -> String? {
        
        let commandSize = String(format: "%02x", UInt(commandIn?.count ?? 0) / 2)
        let newCommand = "8402\(commandSize)\(commandIn ?? "")"
        
        let fullLength = String(format: "%02x", UInt(newCommand.count) / 2)
        let tlvCommand = "C102\(fullLength)\(newCommand)"
        
        return tlvCommand
        
    }
    public func getDeviceInfo(_ deviceType: UInt, connected: Bool, instance: Any!)
    {
        if((instance as! MTSCRA).isDeviceOpened() && self.lib.isDeviceConnected())
        {
            
            if(connected)
            {
                if self.lib.isDeviceConnected() && self.lib.isDeviceOpened()
                {
                    DispatchQueue.main.async {
                        self.btnConnect?.setTitle("Disconnect", for: .normal)
                        self.btnConnect?.alpha = 0.5;
                        self.btnConnect?.isEnabled = false;
                        self.btnConnect?.backgroundColor = UIColor(hex:0xcc3333);
                    }
                    
                    
                    
                    if deviceType == MAGTEKDYNAMAX || deviceType == MAGTEKEDYNAMO || deviceType == MAGTEKTDYNAMO {
                        if let name = (instance as? MTSCRA)?.getConnectedPeripheral().name {
                            self.setText(text:"Connected to \(name)")
                        }
                        
                        
                        if !self.devicePaired! {
                            return
                        }
                        
                        if deviceType == MAGTEKDYNAMAX || deviceType == MAGTEKEDYNAMO || deviceType == MAGTEKTDYNAMO {
                            self.setText(text:"Setting data output to Bluetooth LE...")
                            let response = self.sendCommandSync("480101")!
                            self.setText(text: "[Output Result]\r\(response)")
                            
                            
                            
                        }
                        
                    }
                    var delay = 0.5;
                    if(self.lib.getDeviceType() == MAGTEKKDYNAMO || self.lib.getDeviceType() == MAGTEKIDYNAMO)
                    {
                        delay = 1.5;
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.setText(text: "Getting FW ID...")
                            
                            if self.lib.getDeviceType() == MAGTEKAUDIOREADER {
                                let fw = self.lib.sendCommandSync( self.buildCommand(forAudioTLV: "000100"))
                                guard fw!.count > 4 else {
                                 
                                    self.setText(text: "Unable to get data\r\nRaw return data is \(fw ?? "")")
                                    DispatchQueue.main.async {
                                    self.btnConnect?.isEnabled = true;
                                        self.btnConnect?.alpha = 1;
                                    }
                                    return;
                                }
                            }
                            else
                            {
                                let fw = self.sendCommandSync("000100");
                                guard fw!.count > 4 else {
                                 
                                    self.setText(text: "Unable to get data\r\nRaw return data is \(fw ?? "")")
                                    DispatchQueue.main.async {
                                    self.btnConnect?.isEnabled = true;
                                        self.btnConnect?.alpha = 1;
                                    }
                                    return;
                                }
                                self.setText(text: "[Firmware ID]\n\(String(fw!.suffix(fw!.count - 4)).stringFromHexString)")
                                
                            }
                            
                            self.setText(text: "Getting SN...")
                            if self.lib.getDeviceType() == MAGTEKAUDIOREADER {
                                let sn = self.sendCommandSync( self.buildCommand(forAudioTLV: "000103"))
                                guard sn!.count > 4 else {
                                 
                                    self.setText(text: "Unable to get data\r\nRaw return data is \(sn ?? "")")
                                    DispatchQueue.main.async {
                                    self.btnConnect?.isEnabled = true;
                                        self.btnConnect?.alpha = 1;
                                    }
                                    return;
                                }
                                self.setText(text: "[Device SN]\n\(String(sn!.suffix(sn!.count - 4)).stringFromHexString)")
                                
                            }
                            else
                            {
                                let sn = self.sendCommandSync("000103");
                                guard sn!.count > 4 else {
                                 
                                    self.setText(text: "Unable to get data\r\nRaw return data is \(sn ?? "")")
                                    DispatchQueue.main.async {
                                    self.btnConnect?.isEnabled = true;
                                        self.btnConnect?.alpha = 1;
                                    }
                                    return;
                                }
                                self.setText(text: "[Device SN]\n\(String(sn!.suffix(sn!.count - 4)).stringFromHexString)")
                                
                            }
                            
                            
                            self.setText(text: "Getting Security Level...")
                            
                            if self.lib.getDeviceType() == MAGTEKAUDIOREADER {
                                let secLev = self.sendCommandSync( self.buildCommand(forAudioTLV: "1500"))
                                self.setText(text: "[Security Level]\n\(secLev!)")
                                
                            }
                            else
                            {
                                let secLev = self.sendCommandSync( "1500")
                                self.setText(text: "[Security Level]\n\(secLev!)")
                                
                            }
                            
                            
                            if deviceType == MAGTEKTDYNAMO || deviceType == MAGTEKKDYNAMO
                            {
                                self.setText(text: "Turning on MSR")
                                //let msrRes = self.sendCommandSync( "580101")
                                let msrRes = self.lib.sendCommandSync("580101")
                                self.setText(text: "[MSR Command Result]\n\(msrRes!)")
                                
                                
                                self.setText(text: "Setting Date Time...")
                                self.setDateTime()
                                
                            }
                            
                            DispatchQueue.main.async {
                                //self.btnConnect?.setTitle("Disconnect", for: .normal)
                                self.btnConnect?.alpha = 1;
                                self.btnConnect?.isEnabled = true;
                                //self.btnConnect?.backgroundColor = UIColor(hex:0xcc3333);
                            }
                            
                        }
                    }
                    
                }
            }
            else
            {
                
                self.devicePaired = true
                self.setText(text: "Disconnected")
                DispatchQueue.main.async {
                    self.btnConnect?.setTitle("Connect", for:UIControl.State())
                    self.btnConnect?.backgroundColor = UIColor(hex:0x3465AA);
                    self.btnConnect?.alpha = 1;
                    self.btnConnect?.isEnabled = true;
                }
            }
        }
        else
        {
            self.devicePaired = true
            self.setText(text: "Disconnected")
            DispatchQueue.main.async {
                self.btnConnect?.setTitle("Connect", for:UIControl.State())
                self.btnConnect?.backgroundColor = UIColor(hex:0x3465AA);
                self.btnConnect?.alpha = 1;
                self.btnConnect?.isEnabled = true;
            }
            
            
        }
    }
    
    public func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
        
        if(self.lib.getDeviceType() != MAGTEKKDYNAMO && self.lib.getDeviceType() != MAGTEKIDYNAMO)
        {
            DispatchQueue.global(qos: .userInitiated).async {
                self.getDeviceInfo(deviceType, connected: connected, instance: instance)
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.getDeviceInfo(deviceType, connected: connected, instance: instance)
            }
        }
        //       }
    }
    
    @objc func clearData()
    {
        if self.lib != nil
        {
            self.lib.clearBuffers();
        }
        self.txtData?.text = "";
        self.txtDebugConsole?.text = "";
    }
    
    
    func sendCommand(withCallBack command: String?, completion: @escaping (String?) -> Void)  {
        
        
        
        cmdCompletion = completion
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
           let rs = self.lib.sendcommand(withLength: command)
            guard rs == 0 else {
                self.setText(text: "Send command failed: \(rs)")
                cmdCompletion!("");
                cmdCompletion = nil;
                return;
            }
        }
        
    }
    
    @objc func presentUtilAction()
    {
        let alert = UIAlertController(title: "More Options", message: "Please select an option", preferredStyle: .actionSheet)
        let clearData = UIAlertAction(title: "Clear Data", style: .default) {
            UIAlertAction in
            // Write your code here
            self.clearData();
        }
        
        alert.addAction(clearData)
        if(self.lib.getDeviceType() == MAGTEKDYNAMAX || self.lib.getDeviceType() == MAGTEKEDYNAMO || self.lib.getDeviceType() == MAGTEKTDYNAMO)
        {
        let getRSSI = UIAlertAction(title: "Get RSSI", style: .default) {
            UIAlertAction in
            // Write your code here
            self.lib.getBluetoothRSSI();
        }
        
        alert.addAction(getRSSI)
        }
        let toggleDebug = UIAlertAction(title: "Toggle Debug", style: .default) {
            UIAlertAction in
            // Write your code here
            self.showDebug = !self.showDebug;
            self.txtData?.frame = CGRect(x: (self.txtData?.frame.origin.x)!, y: self.txtData!.frame.origin.y, width: self.txtData!.frame.size.width, height: self.showDebug ? (self.txtData?.frame.size.height)! / 2 : self.txtData!.frame.size.height * 2);
            self.txtDebugConsole!.frame = CGRect(x: self.txtDebugConsole!.frame.origin.x,y: self.txtData!.frame.origin.y + self.txtData!.frame.size.height + 10, width: self.txtDebugConsole!.frame.size.width ,height: self.txtDebugConsole!.frame.size.height);
            self.txtDebugConsole!.isHidden = !self.showDebug;
        }
        
        
        alert.addAction(toggleDebug)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
            // It will dismiss action sheet
        }
        alert.addAction(cancelAction)
        
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem  = self.navigationItem.rightBarButtonItem
            popover.permittedArrowDirections = .up
        }
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func sendCommandSync(_ command: String?) -> String? {
        var deviceRs = ""
        
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        self.sendCommand(withCallBack: command) { data in
            deviceRs = data!
            dispatchSemaphore.signal()
        }
        if dispatchSemaphore.wait(timeout: .now() + 10) == .timedOut {
            
        }
        
        
        return deviceRs
    }
    
    
    func onDataReceived(_ cardDataObj: MTCardData!, instance: Any!) {
        
        DispatchQueue.main.async
            {
                let responseStr = String(format:  "Track.Status: %@\n\nTrack1.Status: %@\n\nTrack2.Status: %@\n\nTrack3.Status: %@\n\nEncryption.Status: %@\n\nBattery.Level: %ld\n\nSwipe.Count: %ld\n\nTrack.Masked: %@\n\nTrack1.Masked: %@\n\nTrack2.Masked: %@\n\nTrack3.Masked: %@\n\nTrack1.Encrypted: %@\n\nTrack2.Encrypted: %@\n\nTrack3.Encrypted: %@\n\nCard.PAN: %@\n\nMagnePrint.Encrypted: %@\n\nMagnePrint.Length: %i\n\nMagnePrint.Status: %@\n\nSessionID: %@\n\nCard.IIN: %@\n\nCard.Name: %@\n\nCard.Last4: %@\n\nCard.ExpDate: %@\n\nCard.ExpDateMonth: %@\n\nCard.ExpDateYear: %@\n\nCard.SvcCode: %@\n\nCard.PANLength: %ld\n\nKSN: %@\n\nDevice.SerialNumber: %@\n\nMagTek SN: %@\n\nFirmware Part Number: %@\n\nDevice Model Name: %@\n\nTLV Payload: %@\n\nDeviceCapMSR: %@\n\nOperation.Status: %@\n\nCard.Status: %@\n\nRaw Data: \n\n%@",
                                         cardDataObj.trackDecodeStatus,
                                         cardDataObj.track1DecodeStatus,
                                         cardDataObj.track2DecodeStatus,
                                         cardDataObj.track3DecodeStatus,
                                         cardDataObj.encryptionStatus,
                                         cardDataObj.batteryLevel,
                                         cardDataObj.swipeCount,
                                         cardDataObj.maskedTracks,
                                         cardDataObj.maskedTrack1,
                                         cardDataObj.maskedTrack2,
                                         cardDataObj.maskedTrack3,
                                         cardDataObj.encryptedTrack1,
                                         cardDataObj.encryptedTrack2,
                                         cardDataObj.encryptedTrack3,
                                         cardDataObj.cardPAN,
                                         cardDataObj.encryptedMagneprint,
                                         cardDataObj.magnePrintLength,
                                         cardDataObj.magneprintStatus,
                                         cardDataObj.encrypedSessionID,
                                         cardDataObj.cardIIN,
                                         cardDataObj.cardName,
                                         cardDataObj.cardLast4,
                                         cardDataObj.cardExpDate,
                                         cardDataObj.cardExpDateMonth,
                                         cardDataObj.cardExpDateYear,
                                         cardDataObj.cardServiceCode,
                                         cardDataObj.cardPANLength,
                                         cardDataObj.deviceKSN,
                                         cardDataObj.deviceSerialNumber,
                                         cardDataObj.deviceSerialNumberMagTek,
                                         cardDataObj.firmware,
                                         cardDataObj.deviceName,
                                         (instance as! MTSCRA ).getTLVPayload(),
                                         cardDataObj.deviceCaps,
                                         (instance as! MTSCRA ).getOperationStatus(),
                                         cardDataObj.cardStatus,
                                         (instance as! MTSCRA ).getResponseData());
                self.setText(text: responseStr)
                
        }
        
    }
    
    func onDeviceResponse(_ data: Data!) {
        if(cmdCompletion != nil)
        {
            let dataStr = HexUtil.toHex(data)
            // DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            DispatchQueue.main.async {
                self.cmdCompletion!(dataStr)
                self.cmdCompletion = nil
            }
            
            
            return;
        }
        
        let dataString = data.hexadecimalString
        commandResult = dataString
        
        self.setText(text: "\n[Command Result]\n\(dataString)")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    func isX() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if #available(iOS 8, *) {
                print(String(format: "%i", Int(UIScreen.main.nativeBounds.size.height)))
                switch Int(UIScreen.main.nativeBounds.size.height) {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                case 1334:
                    print("iPhone 6/6S/7/8")
                case 2208:
                    print("iPhone 6+/6S+/7+/8+")
                case 2436, 2688, 1792, 2778, 2532:
                    return true
                default:
                    print("unknown")
                }
            } else {
                return false
            }
        } else {
            
            print(String(format: "%i", Int(UIScreen.main.nativeBounds.size.height)))
            switch Int(UIScreen.main.nativeBounds.size.height) {
               
            case 2266://iPad mini
                return true
            case 2388, 2732:
                //iPad Pro 11
                return true
            default:
                return false
            }
        }
        return false
        
    }
    func onDeviceError(_ error: Error!) {
        //UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show();
        
    }
    func deviceNotPaired() {
        self.devicePaired = false
        self.setText(text: "Device is not paired")
        lib.closeDevice()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func setDateTime() {
        
        let date = Date()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from:date)-2008
        let month = calendar.component(.month, from:date)
        let day = calendar.component(.day, from:date)
        let hour = calendar.component(.hour, from:date)
        let minute = calendar.component(.minute, from:date)
        let second = calendar.component(.second, from:date)
        
        
        let cmd = "030C"
        let  size = "0018"
        let  deviceSn = "00000000000000000000000000000000"
        let strMonth = String(format: "%02lX", month)
        let strDay = String(format: "%02lX", day)
        let strHour = String(format: "%02lX", hour)
        let strMinute = String(format: "%02lX", minute)
        let strSecond = String(format: "%02lX", second)
        let strYear = String(format: "%02lX", year)
        let commandToSend = "\(cmd)\(size)00\(deviceSn)\(strMonth)\(strDay)\(strHour)\(strMinute)\(strSecond)00\(strYear)"
        let rs = lib.sendExtendedCommand(commandToSend)
        guard rs == 0 else {
            self.setText(text: "Send command failed: \(rs)")
            return;
        }
    }
    
    func onDeviceExtendedResponse(_ data: String!) {
        self.setText(text:"\n[Device Extended Response]\n\(data!)" )
    }
    func scrollTextView(toBottom textView: UITextView?) {
        let range = NSRange(location: textView?.text.count ?? 0, length: 0)
        textView?.scrollRangeToVisible(range)
        
        textView?.isScrollEnabled = false
        textView?.isScrollEnabled = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var yOffset : CGFloat = 0;
        
        if(self.isX())
        {
            yOffset = 30
        }
        
        self.btnConnect?.frame = CGRect(x: 0, y: size.height - 98 - 65 - yOffset + 120, width: size.width, height: 50)
        self.txtData?.frame = CGRect(x: 5, y: 60, width: size.width - 10 , height: size.height - 120 - yOffset)
        self.txtDebugConsole?.frame = CGRect(x: 5, y: size.height - 240 - yOffset + 60 + 10, width: size.width - 10 , height: size.height / 2 - 120 - yOffset)
        self.txtCommand?.frame = CGRect(x: 5 , y: 9, width: size.width - 170, height: 40)
        self.btnSendCommand?.frame = CGRect(x: (self.txtCommand?.frame.origin.x)! + size.width - 170 + 5 , y: 9, width: 75, height: 40)
        self.btnGetSN?.frame = CGRect(x: (self.btnSendCommand?.frame.origin.x)! + 75 + 5 , y: 9, width: 75, height: 40)
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

