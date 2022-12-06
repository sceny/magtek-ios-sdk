//
//  BLEScannerList.swift
//  MTSCRADemo-Swift
//
//  Created by Tam Nguyen on 9/16/15.
//  Copyright © 2015 MagTek. All rights reserved.
//

import UIKit


protocol BLEScanListEvent {
    
    func didSelectBLEReader(_ per: CBPeripheral);
    func didSelectBLEReaderWithInfo(info: MTDeviceInfo);
}

class BLEScannerList: UITableViewController, MTSCRAEventDelegate {
    var lib:MTSCRA?;
    var deviceList:NSMutableArray!;
    var delegate: BLEScanListEvent?;
 
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    init(style: UITableView.Style, lib:MTSCRA) {
        super.init(style: style);
        self.lib = lib
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(lib != nil)
        {
            lib?.delegate = self;
            deviceList = NSMutableArray();
            let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.lib?.startScanningForPeripherals();
                
            }
        }
        

    }
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rescan", style: .plain, target: self, action: #selector(BLEScannerList.rescan));
        self.tableView.delegate = self;
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell");
    }
    @objc func rescan()
    {
        lib?.stopScanningForPeripherals();
        deviceList.removeAllObjects();
        self.tableView.reloadData();
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
             self.lib?.startScanningForPeripherals();
        });
    }
//    func bleReaderDidDiscoverPeripheral()
//    {
//        deviceList = lib?.getDiscoveredPeripherals();
//        self.tableView.reloadData();
//    }
    
    func onDeviceList(_ instance: Any!, connectionType: UInt, deviceList: [Any]!) {
        self.deviceList = ((deviceList as NSArray).mutableCopy() as! NSMutableArray);
        DispatchQueue.main.async{
            self.tableView.reloadData();
        };
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(deviceList == nil) {return 0;}
        return deviceList.count;
    }
    //NOTE: IF USED bleReaderDidDiscoverPeripheral DELEGATE
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath);
//        cell.textLabel?.text = (deviceList?.object(at: indexPath.row) as! CBPeripheral).name;
//
//        return cell;
//    }
    
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
           
            var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
            }
            cell?.textLabel?.text = (deviceList?.object(at: indexPath.row) as! MTDeviceInfo).name;
            cell?.detailTextLabel?.text = String(format: "RSSI: %i",(deviceList?.object(at: indexPath.row) as! MTDeviceInfo).rssi);
            return cell!;
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lib?.stopScanningForPeripherals();
        
        //NOTE: IF USED bleReaderDidDiscoverPeripheral DELEGATE
        //self.delegate?.didSelectBLEReader(self.deviceList?.object(at: indexPath.row) as! CBPeripheral)
        
        self.delegate?.didSelectBLEReaderWithInfo(info: self.deviceList?.object(at: indexPath.row) as! MTDeviceInfo);
    }
   
    
    

}
