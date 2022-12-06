//
//  ViewController.swift
//  tDynamoScanAndConnect
//
//  Created by Yong Guo on 10/14/21.
//


import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MTSCRAEventDelegate {
    
    var lib : MTSCRA = MTSCRA()
    let bQuickChip : Bool = false
    var bInfiniteTransaction :Bool = false
    
    
    var devTable : UITableView!
    var devList : [MTDeviceInfo] = []
    
    @IBOutlet var logText : UITextView?
    @IBOutlet var amountText : UITextField?
    @IBOutlet var commandText : UITextField?
    
    @IBOutlet var sendButton : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lib.delegate = self

        lib.debugInfoCallback = {x in
            print("debug.name  - " + (x?.name ?? ""))
            print("debug.value - " + (x?.value ?? ""))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath as IndexPath)
        cell.textLabel?.text = devList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.removeFromSuperview()
        self.devTable = nil
        
        lib.stopScanningForPeripherals()
        
        lib.setAddress(devList[indexPath.row].address)
        lib.openDevice()
    }
    
    func log (_ info : String) {
        logText?.text += info + "\n"
    }
    
    func onDeviceError(_ error: Error!) {
        log(error.debugDescription)
    }
    
    func onDeviceConnectionDidChange(_ deviceType: UInt, connected: Bool, instance: Any!) {
        log(connected ? "[Connected]" : "[Disconnected]")
        
        if (connected)
        {
            DispatchQueue.main.async {
                self.initialDevice()
            }
        }
    }
    
    func onDeviceResponse(_ data: Data!) {
        log("[Device Response]\n\(data.hexadecimalString)")
    }
    
    func onDeviceExtendedResponse(_ data: String!) {
        log("[Device Extended Response]\n\(data!)" )
    }
    
    func onDataReceived(_ cardDataObj: MTCardData!, instance: Any!) {
        log("[Card Data]")
        log("  Track1  -  \(cardDataObj.maskedTrack1 ?? "")")
        log("  Track2  -  \(cardDataObj.maskedTrack2 ?? "")")
        log("  Track3  -  \(cardDataObj.maskedTrack3 ?? "")")
    }
    
    func onDisplayMessageRequest(_ data: Data!) {
        let dataString = data.hexadecimalString
        log( "[Display Message Request]\n" +  (dataString as String).stringFromHexString);
    }
    
    func onUserSelectionRequest(_ data: Data!) {
        let dataString = data.hexadecimalString;
        log( "[User Selection Request]\n\(dataString) ");
        lib.setUserSelectionResult(0, selection: 0) // select first one.
    }
    
    func onTransactionStatus(_ data: Data!) {
        log("[Transaction Status]\n\(data.hexadecimalString)")
    }
    
    func onARQCReceived(_ data: Data!) {
        log("[ARQC]\n\(data.hexadecimalString)")
        
        if (bQuickChip){
            log("No need to send ARPC ...")
        } else {
            var responseData = Helper.buildARPCfromARQC(arqc: data, approve: true)
            
            DispatchQueue.main.async {
                let response : Data = Data(bytes: responseData, count: responseData.count)
                self.log("ARPC -> \(response.hexadecimalString)")
                self.lib.setAcquirerResponse(&responseData, length: Int32(responseData.count))
            }
        }
    }
    
    func onTransactionResult(_ data: Data!) {
        log("[Transaction Result]\n\(data.hexadecimalString)")
        
        if (bInfiniteTransaction) {
            // delay 1 second for next transaction
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.buttonStartAction()
            }
        }
    }
    
    func bleReaderStateUpdated(_ state: MTSCRABLEState) {
        print("readerStateUpdated - ", state)
        
        if (state == 0) {
            // dispatch in main queue is very important
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.lib.startScanningForPeripherals()
            })
        }
    }
    
    func onDeviceList(_ instance: Any!, connectionType: UInt, deviceList: [Any]!) {
        let devices = deviceList as! [MTDeviceInfo]
        devList.removeAll()
        
        for (_, dev) in devices.enumerated(){
            print (dev.address ?? "")
            print (dev.name ?? "")
            devList.append(dev)
        }
        
        if let currentTable = devTable {
            currentTable.reloadData()
        } else {
        
            // add table view for select device
            let table = UITableView(frame: CGRect(x:100,y:100,width: 300,height: 300))
            table.register(UITableViewCell.self, forCellReuseIdentifier: "deviceCell")
            table.dataSource = self
            table.delegate = self
            
            self.devTable = table
            
            self.view.addSubview(table)
        }
        
        //lib.stopScanningForPeripherals()
    }
    
    func deviceNotPaired() {
        log("Device is not paired")
    }
    
    func bleReaderDidDisconnected(_ connectionInfo: MTConnectionInfo!) {
        log ("Bluetooth LE Reader Disconnected ")
        if let info = connectionInfo {
            log (" status - \(info.disconnectStatus), \(info.disconnectReason)")
        }
    }
    
    func selectDevice() {

        self.lib.setConnectionType(UInt(BLE_EMV))
        self.lib.setDeviceType(UInt32(MAGTEKTDYNAMO))


    }
    
    func initialDevice() {
        sendCommand("580101") // turn on MSR
        setDateTime() // set datetime for EMV transaction
    }
    
    func sendCommand(_ command:String){
        if (!command.isEmpty) {
            //self.lib.sendcommand(withLength: command)
            let resp = lib.sendCommandSync(command)
            log ("Send Command (\(command)) - \(resp ?? "")")
        }
    }
    
    @IBAction func buttonStartAction() {
        let amount = Helper.StringToN12(v: amountText?.text ?? "0")
        let cashback = Helper.StringToN12(v: "0")
        let currencyCode = HexUtil.getBytesFromHexString("0840")
        
        var bAmount : [UInt8] = [0,0,0,0,0,0]
        var bCashback :[UInt8] = [0,0,0,0,0,0]
        var bCurrencyCode :[ UInt8] = [0,0]
        
        memcpy(&bAmount, amount.bytes, 6)
        memcpy(&bCashback, cashback.bytes,6)
        memcpy(&bCurrencyCode, currencyCode?.bytes, 2)
        
        lib.startTransaction(60, // 60 seconds
                             cardType: 7, // MSR + Contact + Contactless (1 + 2 + 4)
                             option: bQuickChip ? 0x80 : 00,
                             amount: &bAmount,
                             transactionType: 0,
                             cashBack: &bCashback,
                             currencyCode: &bCurrencyCode,
                             reportingOption: 2) // report all state changed
    }
    
    @IBAction func buttonCancelAction() {
        bInfiniteTransaction = false
        lib.cancelTransaction()
    }
    
    @IBAction func buttonSendCommandAction() {
        sendButton?.isEnabled = false
        
        let command = commandText?.text ?? ""
        
        sendCommand(command)
        
        sendButton?.isEnabled = true
    }

    
    @IBAction func buttonConnectAction() {
        log("Connect...")
        
        selectDevice()
    }
    
    @IBAction func buttonDisconnectAction() {
        log("Disconnect...")
        
        lib.closeDevice()
    }
    

    func setDateTime() {
        log ("setDateTime")
        let commandToSend = Helper.buildSetDateTimeCommand()
        let resp = lib.sendExtendedCommandSync(commandToSend)
        log ("sendExtendedCommandSync(\(commandToSend) -> \(resp ?? "")")
    }

}

