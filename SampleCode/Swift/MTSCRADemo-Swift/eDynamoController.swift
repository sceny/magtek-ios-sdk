//
//  eDynamoController.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit

//typealias cmdCompBlock = (String?) -> Void


class eDynamoController: MTDataViewerViewController, BLEScanListEvent, UIActionSheetDelegate{
    
    var btnStartEMV:UIButton?;
    var btnGetStatus:UIButton?;
    var userSelection:UIActionSheet?;
    var tmrTimeout:Timer?;
    var opt:optionController?;
    var btnCancel:UIButton?;
    var btnReset:UIButton?;
    var btnOptions:UIButton?;
    var shouldNotOffset : Bool = false
    
    var arqcFormat : UInt8?
    var tempAmount = [UInt8] (repeating: 0, count: 6)
    // var amount = [CChar] (repeating: 0, count: 6)
    var amount = [UInt8] (repeating: 0, count: 6)
     
    var currencyCode = [UInt8] (repeating: 0, count: 2)
    var cashBack = [UInt8] (repeating: 0, count: 6)
    var cmdCompletions: cmdCompBlock?
    
    let ARQC_DYNAPRO_FORMAT : UInt8 = 0x01
    let ARQC_EDYNAMO_FORMAT : UInt8 = 0x00
    
    typealias commandCompletion = (String?) -> Void
    var queueCompletion: commandCompletion?
    
    
    
    //    Byte tempAmount[6];
    //    unsigned char amount[6];
    //    Byte currencyCode[2];
    //    Byte cashBack[6];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arqcFormat = UInt8("0")
        
        let yOffset = (self.navigationController?.navigationBar.frame.size.height ?? 0) + (self.tabBarController?.tabBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height;
        
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(MTDataViewerViewController.presentUtilAction));
        self.title = "Bluetooth LE EMV";
        self.txtData?.frame =  CGRect(x: 5, y: 60, width: self.view.frame.size.width - 10, height: self.view.frame.size.height - 200 - yOffset);
        let btnWidth = self.view.frame.size.width / 4;
        
        btnStartEMV = UIButton(frame: CGRect(x: 5, y: self.view.frame.size.height - 65 - 60 - yOffset, width: btnWidth - 7, height: 40));
        btnStartEMV?.setTitle("Start", for: UIControl.State());
        btnStartEMV?.backgroundColor = UIColor(hex: 0x3465AA);
        btnStartEMV?.addTarget(self, action: #selector(eDynamoController.startEMV), for: .touchUpInside);
        self.view.addSubview(btnStartEMV!);
        
        btnCancel = UIButton(frame: CGRect(x: btnWidth, y: self.view.frame.size.height - 65 - 60 - yOffset, width: btnWidth - 2, height: 40));
        btnCancel?.setTitle("Cancel", for: UIControl.State());
        btnCancel?.backgroundColor = UIColor(hex: 0xCC3333);
        btnCancel?.addTarget(self, action: #selector(eDynamoController.cancelEMV), for: UIControl.Event.touchUpInside);
        
        self.view.addSubview(btnCancel!);
        
        btnReset = UIButton(frame: CGRect(x: (btnWidth * 2), y: self.view.frame.size.height - 65 - 60 - yOffset, width: btnWidth - 2, height: 40));
        btnReset?.setTitle("Reset", for: UIControl.State());
        btnReset?.addTarget(self, action: #selector(eDynamoController.resetDevice), for: UIControl.Event.touchUpInside);
        btnReset?.backgroundColor = UIColor(hex: 0xCC3333);
        self.view.addSubview(btnReset!);
        
        btnOptions = UIButton(frame: CGRect(x: (btnWidth * 3), y: self.view.frame.size.height - 65 - 60 - yOffset, width: btnWidth - 2, height: 40));
        btnOptions?.setTitle("Options", for: UIControl.State());
        btnOptions?.addTarget(self, action: #selector(eDynamoController.presentOption), for: UIControl.Event.touchUpInside);
        btnOptions?.backgroundColor = UIColor(hex: 0xFF9900);
        self.view.addSubview(btnOptions!);
        
        
        
        self.lib = MTSCRA();
        self.lib.delegate = self;
        //self.lib.setDeviceType(UInt32(MAGTEKEDYNAMO));
        self.lib.setConnectionType(UInt(UInt32(BLE_EMV)))
        
        
        
        self.btnConnect?.frame = CGRect(x: 0, y: self.view.frame.size.height - 65 - yOffset, width: self.view.frame.size.width, height: 50)

        self.btnConnect?.removeTarget(self, action: nil, for: .touchUpInside);
        self.btnConnect?.addTarget(self, action: #selector(connectBLEDevices), for: .touchUpInside);
        self.txtData?.text =  String(format: "App Version: %@.%@ , SDK Version: %@", Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! CVarArg,  Bundle.main.infoDictionary!["CFBundleVersion"] as! CVarArg, self.lib.getSDKVersion());
        
        // Do any additional setup after loading the view.
        
        if UIDevice.current.userInterfaceIdiom == .phone && !shouldNotOffset {
            let navHeight = Int((navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height)
            self.btnSendCommand!.frame = btnSendCommand!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            txtCommand!.frame = self.txtCommand!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnGetSN!.frame = self.btnGetSN!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.txtData!.frame = self.txtData!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnStartEMV!.frame = self.btnStartEMV!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnCancel!.frame = self.btnCancel!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnReset!.frame = self.btnReset!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnOptions!.frame = self.btnOptions!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.btnConnect!.frame = self.btnConnect!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
        }
        
        if(opt == nil)
        {
            opt = optionController(style: UITableView.Style.grouped);
            opt?.lib = self.lib
            opt?.delegate = self
            
        }
        
         self.lib.debugInfoCallback = { debugInfo in
                   
                   let debugString = String(format: "Name: %@\r\nDomain: %d\r\nDescription: %@\r\nTime Stamp:%@\r\n", debugInfo!.name, debugInfo!.debugDomain, debugInfo!.value, debugInfo!.timeStamp! as CVarArg ) ;// [ stringWithFormat:@"Name: %@\r\nDomain: %d\r\nDescription: %@\r\nTime Stamp:%@\r\n", debugInfo.name, debugInfo.debugDomain, debugInfo.value, debugInfo.timeStamp];
                   self.setDebugText(text: debugString);
               };
    }
    func bleReaderDidDisconnected(_ connectionInfo: MTConnectionInfo!) {
        if((connectionInfo) != nil)
        {
            self.setText(text: String(format: "[Bluetooth Device Disconnected]\r\nStatus: %i\r\nDescription: %@", connectionInfo.disconnectStatus, connectionInfo.disconnectReason));
            
        }
        else
        {
            self.setText(text:"[Bluetooth Device Disconnected]\r\nNo Error");
        }
    }
    @objc func connectBLEDevices()
    {
        
        if(self.lib.isDeviceOpened())
        {
            self.lib.clearBuffers();
            self.lib.closeDevice();
            
            return;
            
        }
        
        let alert = UIAlertController(title: "Bluetooth LE EMV Type", message: "Which device are you connecting to", preferredStyle: .alert)
        
        let eDynamo = UIAlertAction(title: "eDynamo", style: .default, handler: { action in
            DispatchQueue.main.async(execute: {
                self.lib.setDeviceType(UInt32(MAGTEKEDYNAMO))
                self.scanForBLE()
            })
            
        })
        let tDynamo = UIAlertAction(title: "tDynamo", style: .default, handler: { action in
            DispatchQueue.main.async(execute: {
                self.lib.setDeviceType(UInt32(MAGTEKTDYNAMO))
                self.scanForBLE()
            })
        })
        let btnCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
        })
        alert.addAction(eDynamo)
        alert.addAction(tDynamo)
        alert.addAction(btnCancel)
        present(alert, animated: true)
        
        
    }
    
    
    
    @objc func cancelEMV()
    {
        
        DispatchQueue.global(qos: .background).async {
        self.lib.cancelTransaction();
            
            self.setText(text: "Background thread ran successfully")
        };
    }
    @objc func resetDevice()
    {
        //self.lib.sendcommand(withLength: "0200");
        //020100
        let rs = self.lib.sendcommand(withLength: "020100");
        guard rs == 0 else {
            self.setText(text: "Send command failed with code: \(rs)")
            return;
        }
    }
    
    @objc func presentOption()
    {
        
        if(opt == nil)
        {
            opt = optionController(style: UITableView.Style.grouped);
            opt?.lib = self.lib
            opt?.delegate = self
            
        }
        self.navigationController?.pushViewController(opt!, animated: true);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didSelectBLEReader(_ per: CBPeripheral) {
        
        self.lib.delegate = self
        self.navigationController?.popViewController(animated: true);
        self.lib.setAddress(per.identifier.uuidString);
        self.lib.openDevice();
        self.setText(text: "Connecting...")
        // super.connect()
    }
    func didSelectBLEReaderWithInfo(info: MTDeviceInfo) {
        self.lib.delegate = self;
        self.navigationController?.popViewController(animated: true);
        self.lib.setAddress(info.address);
        // self.lib .setUUIDString(per.identifier.uuidString);
        self.lib.openDevice();
        self.setText(text: "Connecting...")
    }
    func didGetRSSI(_ RSSI: Int32, error: Error!) {
        self.setText(text:String(format:  "[Bluetooth Signal Strength]\r\n%i", RSSI));
    }
    override func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
        super.onDeviceConnectionDidChange(deviceType, connected: connected, instance: instance as AnyObject?)
        if(connected)
        {
            self.lib.getBluetoothRSSI();
        }
        if(!self.devicePaired!)
        {
            self.lib.closeDevice();
        }
    }
    
    //    func didSelectBLEReader(_ per: CBPeripheral) {
    //        self.lib.delegate = self;
    //        self.navigationController?.popViewController(animated: true);
    //        self.lib.setAddress(per.identifier.uuidString);
    //        self.lib.openDevice();
    //    }
    
    @objc func scanForBLE()
    {
        let list = BLEScannerList(style: .plain, lib: lib);
        list.delegate = self;
        self.navigationController?.pushViewController(list, animated: true);
    }
    
    @objc func startEMV()
    {
        
        if(self.lib!.isDeviceOpened() && self.lib!.isDeviceConnected())
        {
            let alert = UIAlertView(title: "Enter amount", message: "Enter amount for transaction", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Start")
            alert.alertViewStyle = .plainTextInput
            alert.textField(at: 0)?.keyboardType = .decimalPad
            alert.tag = 0
            alert.show()
        }
        
        //       return
        
        //        let timeLimit:UInt8 = 0x3c;
        //        let cardType:UInt8 = 0x02;
        //        let option :UInt8 = 0x00;
        //        var amount:[UInt8] = [0x00, 0x00, 0x00, 0x00, 0x15, 0x00];
        //        let transactionType:UInt8 = 0x00;
        //        var cashBack:[UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        //        var currencyCode:[UInt8] = [ 0x08, 0x40];
        //        let reportingOption:UInt8 = 0x01;
        //        self.lib.startTransaction(timeLimit, cardType: cardType, option: option, amount: &amount, transactionType: transactionType, cashBack: &cashBack, currencyCode: &currencyCode, reportingOption: reportingOption);
    }
    
    func getUserFriendlyLanguage(_ codeIn: String) -> String
    {
        let lanCode:NSDictionary = ["EN": "English","DE": "Deutsch","FR": "Français","ES": "Español","ZH": "中文","IT": "Italiano"];
        
        return lanCode.object(forKey: codeIn.uppercased()) as! String;
    }
    override func onDisplayMessageRequest(_ data: Data!) {
        if(data != nil)
        {
            let dataString = data.hexadecimalString
            
            DispatchQueue.main.async
                {
                    
                    self.setText(text:( "\n[Display Message Request]\n" +  (dataString as String).stringFromHexString));
            }
        }
    }
    override func onEMVCommandResult(_ data: Data!) {
        
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            // self.txtData?.text = self.txtData!.text + "\n[EMV Command Result]\n\(dataString)";
            self.setText(text:"[EMV Command Result]\n\(dataString)");
        }
    }
    override func onUserSelectionRequest(_ data: Data!) {
        
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            
            self.setText(text:  "\n[User Selection Request]\n\(dataString) ");
            var dataType = [UInt8](repeating: 0, count: 1);
            //(data.subdata(in: NSMakeRange(0, 1)) as NSData).getBytes(&dataType, length: 1);
            dataType = data.subdata(in: 0 ..< 1).toArray(type: UInt8.self)
            
            var timeOut:NSInteger = 0;
            //(data.subdata(in: NSMakeRange(1, 1)) as NSData).getBytes(&timeOut, length:1);
            (data.subdata(in:  1 ..< 2) as NSData).getBytes(&timeOut, length: MemoryLayout<Int>.size)
            var dataSTr = data.subdata(in: 2 ..< data.count - 1).hexadecimalString;
            let menuItems:[String] = data.subdata(in: 2 ..< data.count - 1).hexadecimalString.components(separatedBy: "00");//.components(separatedBy: "00");
            
            
            
            self.userSelection = UIActionSheet();
            self.userSelection?.title = (menuItems[0] ).stringFromHexString;
            self.userSelection?.delegate = self;
            
            for i in 1 ..< menuItems.count
            {
                if((dataType[0] & 0x01) == 1)
                {
                    self.userSelection?.addButton(withTitle: self.getUserFriendlyLanguage((menuItems[i] ).stringFromHexString));
                    
                }
                else
                {
                    self.userSelection?.addButton(withTitle: (menuItems[i] ).stringFromHexString);
                    
                }
            }
            
            self.userSelection?.destructiveButtonIndex = (self.userSelection?.addButton(withTitle: "Cancel"))!;
            self.userSelection?.show(in: self.view);
            if(timeOut > 0 )
            {
                self.tmrTimeout = Timer.scheduledTimer(timeInterval: Double(timeOut), target: self, selector: #selector(eDynamoController.selectionTimedOut), userInfo: nil, repeats: false);
                
            }
            
            
            
        }
    }
    
    
    @objc func selectionTimedOut()
    {
        userSelection?.dismiss(withClickedButtonIndex: (userSelection?.destructiveButtonIndex)!, animated: true);
        self.lib.setUserSelectionResult(0x02, selection: UInt8((userSelection?.destructiveButtonIndex)! ));
        UIAlertView(title: "Transaction Timed Out", message: "User took too long to enter a selection, trasnaction has been canceled", delegate: nil, cancelButtonTitle: "Done").show();
        
    }
    override func onTransactionStatus(_ data: Data!) {
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            //self.txtData?.text = self.txtData!.text + "\n[Transaction Status]\n\(dataString)";
            self.setText(text: "[Transaction Status]\n\(dataString)")
        }
    }
    
    
    
    override func onDeviceResponse(_ data: Data!) {
        super.onDeviceResponse(data)
    }
    
    override func onARQCReceived(_ data: Data!) {
        let dataString = data.hexadecimalString;
        let emvBytes  = HexUtil.getBytesFromHexString(dataString)
        let tlv = (emvBytes)!.parseTLVData();
        
        DispatchQueue.main.async{
            //self.txtData!.text = self.txtData!.text + "\n[ARQC Received]\n\(dataString)"
            self.setText(text: "[ARQC Received]\n\(dataString)")
            if tlv != nil {
                
                if (self.opt?.isQuickChip())!
                {
                    self.setText(text: "\n[Quick Chip]\r\nNot sending response\n")
                    return
                }
                
                var snStr = ""
                if let tempTLVObj = tlv?["DFDF25"] as? MTTLV
                {
                    snStr = tempTLVObj.value
                    self.setText(text: "\nSN String = \(snStr.stringFromHexString)")
                }
                
                var dfdf55Str = ""
                if let tempTLVObj = tlv?["DFDF55"] as? MTTLV
                {
                    dfdf55Str = tempTLVObj.value
                }
                
                var dfdf54Str = ""
                if let tempTLVObj = tlv?["DFDF54"] as? MTTLV
                {
                    dfdf54Str = tempTLVObj.value
                }
                
                
                var response : Data
                if self.arqcFormat == self.ARQC_EDYNAMO_FORMAT
                {
                    
                    response = self.buildAcquirerResponse(HexUtil.getBytesFromHexString(snStr)! as Data, encryptionType: Data(), ksn: Data(), approved: (self.opt?.shouldSendApprove())!)
                }
                else
                {
                    response = self.buildAcquirerResponse(HexUtil.getBytesFromHexString(snStr)! as Data,  encryptionType: HexUtil.getBytesFromHexString(dfdf55Str)! as Data, ksn:HexUtil.getBytesFromHexString(dfdf54Str)! as Data, approved: true )
                    
                }
                self.setText(text: "\n[Send Respond]\n\(response.hexadecimalString)")
                
                self.lib.setAcquirerResponse(UnsafeMutablePointer<UInt8> (mutating: (response as NSData).bytes.bindMemory(to: UInt8.self, capacity: response.count)), length: Int32( response.count))
                
            }
            
        }
        
    }
    
    
    func buildAcquirerResponse(_ deviceSN: Data,  encryptionType: Data,ksn: Data, approved: Bool) ->Data
    {
        let response  = NSMutableData();
        var lenSN = 0;
        if (deviceSN.count > 0)
        {
            lenSN = deviceSN.count;
            
        }
        //
        let snTagByte:[UInt8] = [0xDF, 0xdf, 0x25, UInt8(lenSN)];
        let snTag = Data(fromArray: snTagByte)
        
        var encryptLen:UInt8 = 0;
        _ = Data(bytes: &encryptLen, count: MemoryLayout.size(ofValue: encryptionType.count))
        
        let encryptionTypeTagByte:[UInt8] = [0xDF, 0xDF, 0x55, 0x01];
        let encryptionTypeTag =  Data(fromArray: encryptionTypeTagByte)
        
        var ksnLen:UInt8 = 0;
        _ = Data(bytes: &ksnLen, count: MemoryLayout.size(ofValue: encryptionType.count))
        let ksnTagByte:[UInt8] = [0xDF, 0xDF, 0x54, 0x0a];
        let ksnTag = Data(fromArray: ksnTagByte)
        
        let containerByte:[UInt8] = [0xFA, 0x06, 0x70, 0x04];
        let container = Data(fromArray: containerByte)
        
        
        
        
        
        let approvedARCByte:[UInt8] = [0x8A, 0x02, 0x30,0x30];
        let approvedARC = Data(fromArray: approvedARCByte)
        //
        let declinedARCByte:[UInt8] = [0x8A, 0x02, 0x30,0x35];
        let declinedARC = Data(fromArray: declinedARCByte)
        
        let macPadding:[UInt8] = [0x00, 0x00,0x00,0x00,0x00,0x00,0x01,0x23, 0x45, 0x67];
        
        var len = 2 + snTag.count + lenSN + container.count + approvedARC.count ;
        if(arqcFormat == ARQC_DYNAPRO_FORMAT)
        {
            len += encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count;
        }
        
        var len1 = (UInt8)((len >> 8) & 0xff);
        var len2 = (UInt8)(len & 0xff);
        
        var tempByte = 0xf9;
        response.append(&len1, length: 1)
        response.append(&len2, length: 1)
        response.append(&tempByte, length: 1)
        tempByte = (len - 2)
        if(arqcFormat == ARQC_DYNAPRO_FORMAT)
        {
            tempByte = encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count +  snTag.count + lenSN + container.count + approvedARC.count;
            
        }
        response.append(&tempByte, length: 1)
        if(arqcFormat == ARQC_DYNAPRO_FORMAT)
        {
            response.append(ksnTag);
            response.append(ksn);
            response.append(encryptionTypeTag);
            response.append(encryptionType);
        }
        
        response.append(snTag);
        response.append(deviceSN);
        response.append(container);
        if(approved)
        {
            response.append(approvedARC);
        }
        else{
            response.append(declinedARC);
            
        }
        
        if(arqcFormat == ARQC_DYNAPRO_FORMAT)
        {
            response.append(Data(fromArray: macPadding))
        }
        
        return response as Data;
        
    }
    
    
    
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if((tmrTimeout) != nil)
        {
            tmrTimeout?.invalidate();
            tmrTimeout = nil;
            
        }
        
        
        if(buttonIndex == actionSheet.destructiveButtonIndex)
        {
            self.lib .setUserSelectionResult(0x01, selection: 0x00);
            return;
        }
        
        self.lib .setUserSelectionResult(0x00, selection: UInt8(buttonIndex));
        
        
        
        
    }
    
    func onTransactionResult(_ data: Data!) {
        let tempDataObj : NSData = (data as NSData)
        
        let dataString = data.hexadecimalString;
        DispatchQueue.main.async{
            self.setText(text: "\n[Transaction Result]\n\(dataString)");
            let dataString = tempDataObj.subdata(with: NSRange(location: 1, length: data.count-1)).hexadecimalString
            
            let emvBytes = HexUtil.getBytesFromHexString(dataString as String);
            let tlv = (emvBytes! as NSData).parseTLVData();
            let dataDump = tlv?.dumpTags();
            //let responseTag = HexUtil.getBytesFromHexString((tlv?.object(forKey: "9F27") as! MTTLV).value);
            
            if(self.arqcFormat == self.ARQC_EDYNAMO_FORMAT)
            {
                let responseTag = HexUtil.getBytesFromHexString((tlv!["DFDF1A"] as! MTTLV).value)
                self.setText(text: "\n[Parsed Transaction Result]\n \(dataDump!)")
                let sigReq : NSData = tempDataObj.subdata(with: NSRange(location: 0, length: 1)) as NSData
                
                if(sigReq[0] == 0x01 && (responseTag![0] == 0x00))
                {
                    UIAlertView(title: "Signature", message: "Signature required, please sign.", delegate: self, cancelButtonTitle: "Ok").show()
                    let sig = eDynamoSignature()
                    self.navigationController?.pushViewController(sig, animated: true)
                    
                }
            }
        }
    }
    
    func led(on: Int, completion: @escaping cmdCompBlock) -> Int {
        let rs = lib.sendcommand(withLength: String(format: "4D010%i", on))
        if rs == 0 {
            cmdCompletion = completion
        }
        //0 - sent successful
        //15 - device is busy
        return Int(rs)
    }
    
    
    
    override func onDeviceError(_ error: Error!) {
        super.onDeviceError(error)
        DispatchQueue.main.async
            {
            self.txtData!.text = self.txtData!.text + "\n" + error.localizedDescription
        }
    }
    func bleReaderStateUpdated(_ state: MTSCRABLEState) {
        if state == UNSUPPORTED
        {
            UIAlertView(title: "Bluetooth LE Error", message: "Bluetooth LE is unsupported on this device", delegate: nil, cancelButtonTitle: "OK").show()
            
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func onDataReceived(_ cardDataObj: MTCardData!, instance: Any!) {
        super.onDataReceived(cardDataObj, instance: instance)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var yOffset : CGFloat = 0;
        
        if(self.isX())
        {
            yOffset = 30
        }
        
        let btnWidth: CGFloat = size.width / 4
        self.btnStartEMV?.frame = CGRect(x: 5, y: size.height - 98 - yOffset, width: btnWidth - 7, height: 40)
        self.btnCancel?.frame = CGRect(x: btnWidth, y: size.height - 98 - yOffset, width: btnWidth - 2, height: 40)
        self.btnReset?.frame = CGRect(x: (btnWidth * 2), y: size.height - 98 - yOffset, width: btnWidth - 2, height: 40)
        self.btnOptions?.frame = CGRect(x: (btnWidth * 3), y: size.height - 98 - yOffset, width: btnWidth - 2, height: 40)
        self.btnConnect?.frame = CGRect(x: 0, y: size.height - 98 - 65 + 120 - yOffset, width: size.width, height: 50)
        self.txtData?.frame = CGRect(x: 5, y: 60, width: size.width - 10, height: size.height - 370 - yOffset + 195)
        self.txtCommand?.frame = CGRect(x: 5 , y: 9, width: size.width - 170, height: 40)
        self.btnSendCommand?.frame = CGRect(x: (self.txtCommand?.frame.origin.x)! + size.width - 170 + 5 , y: 9, width: 75, height: 40)
        self.btnGetSN?.frame = CGRect(x: self.btnSendCommand!.frame.origin.x + 75 + 5 , y: 9, width: 75, height: 40)
    }
}

extension eDynamoController: optionControllerEvent
{
    func didSelectSetDateTime() {
        setDateTime()
        self.navigationController?.popViewController(animated: true)
    }
    // override  func setDateTime() {
    
    //        let date = Date()
    //
    //        let calendar = Calendar.current
    //        let year = calendar.component(.year, from:date)-2008
    //        let month = calendar.component(.month, from:date)
    //        let day = calendar.component(.day, from:date)
    //        let hour = calendar.component(.hour, from:date)
    //        let minute = calendar.component(.minute, from:date)
    //        let second = calendar.component(.second, from:date)
    //
    //
    //        let cmd = "030C"
    //        let  size = "0018"
    //        let  deviceSn = "00000000000000000000000000000000"
    //        let strMonth = String(format: "%02lX", month)
    //        let strDay = String(format: "%02lX", day)
    //        let strHour = String(format: "%02lX", hour)
    //        let strMinute = String(format: "%02lX", minute)
    //        let strSecond = String(format: "%02lX", second)
    //        // NSString* placeHol = [NSString stringWithFormat:@"%02lX", (long)second];
    //        let strYear = String(format: "%02lX", year)
    //        let commandToSend = "\(cmd)\(size)00\(deviceSn)\(strMonth)\(strDay)\(strHour)\(strMinute)\(strSecond)00\(strYear)"
    //        lib.sendExtendedCommand(commandToSend)
    //   }
    
    
    func didSelectConfigCommand(_ command: Data!) {
        self.navigationController?.popViewController(animated: true)
        // var temp = "\x00"
        
        if memcmp((command.subdata(in:  1 ..< 2) as NSData).bytes,"\u{05}", 1) == 0 {
            setTerminalConfiguration(commandIn: command)
        }
        else if memcmp((command.subdata(in:  1 ..< 2) as NSData).bytes, "\u{06}", 1) == 0 {
            getTerminalConfiguration(commandIn: command)
        }
        else if memcmp((command.subdata(in:  1 ..< 2) as NSData).bytes, "\u{0e}", 1) == 0 {
            commitConfiguration()
        }
    }
    
    func getTerminalConfiguration(commandIn : Data)
    {
        let command = "0306"
        let length = "0003"
        let slotNumber = "01"
        let operation = "0F"
        let databaseSelector = "00"
        print("\(command)\(length)\(slotNumber)\(operation)\(databaseSelector)")
        let rs = self.lib.sendExtendedCommand("\(command)\(length)\(slotNumber)\(operation)\(databaseSelector)")
        guard rs == 0 else {
            self.setText(text: "Send command failed: \(rs)")
            return;
        }
    }
    
    func setTerminalConfiguration(commandIn:Data)
    {
        
        let command = "0305"
        let serialNumber = "42324645304542303932393135414100" //CHANGE TO REAL DEVICE SERIAL NUMBER
        let macType = "00"
        let slotNumber = "01"
        let operation =  "01"
        let databaseSelector =  "00"
        let objectsToWrite = "FA00"
        let MAC = "00000000"//PASS IN VALID MAC
        let length = "001A" //two byte length
        print("\(command)\(length)\(macType)\(slotNumber)\(operation)\(databaseSelector)\(serialNumber)\(objectsToWrite)\(MAC)")
        let rs = self.lib.sendExtendedCommand("\(command)\(length)\(macType)\(slotNumber)\(operation)\(databaseSelector)\(serialNumber)\(objectsToWrite)\(MAC)")
        guard rs == 0 else {
            self.setText(text: "Send command failed: \(rs)")
            return;
        }
        
    }
    
    func commitConfiguration()
    {
        let command = "030E" // Commit Configuration Command
        
        let databaseSelector = "00" // Contact L2 EMV
        let length = "0001"
        print("\(command)\(length)\(databaseSelector)")
        
        let rs = self.lib.sendExtendedCommand("\(command)\(length)\(databaseSelector)")
        guard rs == 0 else {
            self.setText(text: "Send command failed: \(rs)")
            return;
        }
    }
    func getARQCFormat(_ completion: @escaping commandCompletion) -> Int {
        
        let rs = lib.sendcommand(withLength: "000168")
        if rs == 0 {
            queueCompletion = completion
        }
        //0 - sent successful
        //15 - device is busy
        return Int(rs)
        
        
    }
    //    func onDeviceExtendedResponse(_ data: String!) {
    //        super.onDeviceExtendedResponse(data)
    //    }
    
    //    func getARQCFormat() -> Int {
    //        let rs = self.lib.sendcommand(withLength: "000168")
    //        //0 - sent successful
    //        //15 - device is busy
    //        return Int(rs);
    ////        if let tempResponse = self.sendCommandSync("000168")
    ////        {
    ////            if !tempResponse.isEmpty
    ////            {
    ////            return Int(tempResponse)!
    ////            }
    ////            else
    ////            {
    ////                return 0
    ////            }
    ////        }
    ////        else
    ////        {
    ////            return 0
    ////        }
    //       // return Int(self.sendCommandSync("000168")!)!
    //    }
    
    //    func getARQCFormat(_ completion: @escaping cmdCompBlock) -> Int {
    //        return Int(self.sendCommandSync("000168")!)!
    //        let rs = lib.sendcommand(withLength: "000168")
    //        if rs == 0 {
    //            self.cmdCompletions = completion
    //        }
    //        //0 - sent successful
    //        //15 - device is busy
    //        return Int(rs)
    //
    //
    //    }
    
    
}
extension eDynamoController : UIAlertViewDelegate
{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 || buttonIndex == 2
        {
            var txtAmount = alertView.textField(at: 0)?.text
            if txtAmount!.isEmpty
            {
                txtAmount = "0"
            }
            if txtAmount!.count > 0
            {
                if alertView.tag == 0
                {
                    let dataAmount = HexUtil.getBytesFromHexString(txtAmount!)
                    memcpy(&tempAmount, dataAmount?.bytes, 6)
                    var i = 5
                    while i >= 0 {
                        // amount[i] = CChar(tempAmount[5 - i])
                        amount[i] = tempAmount[5 - i]
                        
                        i -= 1
                    }
                    memcpy(&tempAmount, amount,6);
                }
                else{
                    memcpy(&amount, &tempAmount,6);
                }
                let timeLimit : UInt8 = 0x3C
                let cardType = opt?.getCardType()
                
                
                
                var option : UInt8  = 0x00;
                if (opt?.isQuickChip())!
                {
                    option |= 0x80
                }
                let transactionType : UInt8 = (opt?.getPurchaseOption())!
                
                cashBack[0] = 0x00;
                cashBack[1] = 0x00;
                cashBack[2] = 0x00;
                cashBack[3] = 0x00;
                cashBack[4] = 0x00;
                cashBack[5] = 0x00;
                
                currencyCode[0] =  0x08;
                currencyCode[1] = 0x40;
                var reportingOption : UInt8 = 1;
                
                if (opt != nil) {
                    reportingOption = opt!.getReportingOption()
                }
                
                if opt!.getPurchaseOption() & 0x02 != 0 {
                    if alertView.tag != 1 {
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertView(title: "Enter Cashback Amount", message: "Enter amout for Cashback", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
                            alert.alertViewStyle = .plainTextInput
                            alert.textField(at: 0)?.keyboardType = .decimalPad
                            alert.tag = 1
                            alert.show()
                            
                        })
                        return
                    } else {
                        let dataAmount = HexUtil.getBytesFromHexString(txtAmount!)
                        //HexUtil.data(fromHexString: txtAmount)
                        
                        memcpy(&tempAmount, dataAmount?.bytes, 6)
                        
                        var i = 5
                        while i >= 0 {
                            cashBack[i] = tempAmount[5 - i]
                            i -= 1
                        }
                    }
                }
                sendCommand(withCallBack: "000168") { data in
                    
                    let format = data ?? ""
                    var tempFormat : NSString = ""
                    tempFormat = "\(format)" as NSString
                    
                    if tempFormat.substring(to: 1) == "02"
                    {
                        self.arqcFormat = 0x00
                    }
                    else
                    
                    {
                        let tempData : NSData  = HexUtil.getBytesFromHexString(tempFormat as String)!
                        if tempData.length > 2
                        {
                            let data : NSData = tempData.subdata(with: NSRange(location: 2, length: 1)) as NSData
                            data.getBytes(&self.arqcFormat, length: 1)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.lib.startTransaction(timeLimit, cardType:cardType!, option: option, amount: &self.amount, transactionType: transactionType, cashBack: &self.cashBack, currencyCode: &self.currencyCode, reportingOption: reportingOption)
                    }
                }
                
            }
            
        }
        
    }
}

