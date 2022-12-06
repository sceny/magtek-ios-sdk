//
//  optionController.swift
//  MTSCRADemo-Swift
//
//  Created by Ramu Guttula on 07/08/19.
//  Copyright © 2019 MagTek. All rights reserved.
//

import UIKit
@objc protocol optionControllerEvent: NSObjectProtocol {
    @objc optional func didSelectConfigCommand(_ command: Data?)
    @objc optional func didSelectSetDateTime()
}

class optionController: UITableViewController {

    var optionArray : [String] = []
    var optionValue : [[String]] = []
    var optionDict: [String : NSNumber] = [:]
    weak var delegate: optionControllerEvent?
    var lib: MTSCRA!
    var selectedCardArray : [IndexPath] = []
    
    init(greeting:String) {
       // self.greeting = greeting
        super.init(style: .plain)
    }

    
    override init(style:UITableView.Style)
    {
        
        
            self.optionArray = [
                "Transaction Type",
                "Reporting Option",
                "Acquire Response",
                "Terminal Configuration Command",
                //"BLE Demo",
                "Card Type",
                "Option",
                "Misc. Commands"
            ]
            
            
            self.optionValue = [
                [
                    "Purchase",
                    "Cash Back with Purchase",
                    "Goods",
                    "Services",
                    "International Goods (Purchase)",
                    " International Cash Advance or Cash Back",
                    "Domestic Cash Advance or Cash Back"
                ],
                [
                    "Termination Status Only ",
                    "Major Status Changes ",
                    "All Status Changes "
                ],
                ["Approve", "Decline"],
                [
                    "0x0305 - Set Terminal Configuration",
                    "0x0306 - Get Terminal Configuration",
                    "0x030E - Commit Configuration"
                ],
                //["Initiate Pairing Demo"],
                ["MSR",
                 "Contact",
                 "Contactless"
                ],
                ["Qwick Chip"],
                ["Set Date Time"]
                
            ]
            
            self.optionDict = [
                "ApproveSelection" : NSNumber(value: 0),
                "PurchaseOption" : NSNumber(value: 0),
                "ReportingOption" : NSNumber(value: 1),
                "CardType" : NSNumber(value: 1),
                "QuickChip" : NSNumber(value: 0)
            ]
            
            self.selectedCardArray.append(IndexPath(row: 0, section: 4))
            self.selectedCardArray.append(IndexPath(row: 1, section: 4))

        super.init(style: style)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = "Options"
        super.viewDidLoad()
//        optionArray = [
//            "Transaction Type",
//            "Reporting Option",
//            "Acquire Response",
//            "Terminal Configuration Command",
//            "BLE Demo",
//            "Card Type",
//            "Option",
//            "Misc. Commands"
//        ]
//        
//        
//        optionValue = [
//            [
//                "Purchase",
//                "Cash Back with Purchase",
//                "Goods",
//                "Services",
//                "International Goods (Purchase)",
//                " International Cash Advance or Cash Back",
//                "Domestic Cash Advance or Cash Back"
//            ],
//            [
//                "Termination Status Only ",
//                "Major Status Changes ",
//                "All Status Changes "
//            ],
//            ["Approve", "Decline"],
//            [
//                "0x0305 - Set Terminal Configuration",
//                "0x0306 - Get Terminal Configuration",
//                "0x030E - Commit Configuration"
//            ],
//            ["Initiate Pairing Demo"],
//            ["MSR",
//             "Contact",
//             "Contactless"
//            ],
//            ["Qwick Chip"],
//            ["Set Date Time"]
//            
//        ]
//        
//        optionDict = [
//            "ApproveSelection" : NSNumber(value: 0),
//            "PurchaseOption" : NSNumber(value: 0),
//            "ReportingOption" : NSNumber(value: 0),
//            "CardType" : NSNumber(value: 1),
//            "QuickChip" : NSNumber(value: 0)
//        ]
//        
//        selectedCardArray.append(IndexPath(row: 0, section: 5))
//        selectedCardArray.append(IndexPath(row: 1, section: 5))
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the number of sections.
        return optionArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return optionValue[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return optionArray[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        cell.textLabel?.text = optionValue[indexPath.section][indexPath.row]
        if indexPath.section == 2 {
            
            if  ( optionDict["ApproveSelection"])?.intValue ?? 0 == indexPath.row
            {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
        } else if indexPath.section == 1 {
            if ( optionDict["ReportingOption"])?.intValue ?? 0 == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if indexPath.section == 0 {
            if ( optionDict["PurchaseOption"])?.intValue ?? 0 == indexPath.row {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        else if indexPath.section == 4
        {
            if(selectedCardArray.contains(indexPath))
            {
                cell.accessoryType = .checkmark
                
            }
            else
            {
                cell.accessoryType = .none
            }
        }
        else if (indexPath.section == 5)
        {
            if( ( optionDict["QuickChip"])?.intValue == 1)
            {
                cell.accessoryType = .checkmark
                
            }
            else
            {
                cell.accessoryType = .none
            }
        }
        else
        {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            optionDict["ApproveSelection"] = NSNumber(value: Int32(indexPath.row))
        }
        if indexPath.section == 1 {
            optionDict["ReportingOption"] = NSNumber(value: Int32(indexPath.row))
        }
        if indexPath.section == 0 {
            optionDict["PurchaseOption"] = NSNumber(value: Int32(indexPath.row))
        }
        
        if indexPath.section == 3 {
            if (delegate?.responds(to: #selector(eDynamoController.didSelectConfigCommand(_:))))! {
                if indexPath.row == 0 {
                    var tempByte : [UInt8] = [0x03, 0x05]
                    //NSData(bytes: &tempByte, length: 2)
                    delegate?.didSelectConfigCommand?(NSData(bytes: &tempByte, length: 2) as Data)
                    //delegate.didSelectConfigCommand(Data(bytes: &tempByte, length: 2))
                } else if indexPath.row == 1 {
                    var tempByte : [UInt8] = [0x03, 0x06]
                    delegate?.didSelectConfigCommand?(NSData(bytes: &tempByte, length: 2) as Data)
                } else {
                    var tempByte : [UInt8] = [0x03, 0x0e]
                    delegate?.didSelectConfigCommand?(Data(bytes: &tempByte, count: 2))
                   // delegate?.didSelectConfigCommand(Data(bytes: &tempByte, count: 2))
                }
            }
        }
        
        /*
        if indexPath.section == 4 {
            let scannerList = BLEScannerList(style: .grouped, lib: lib)
            scannerList.delegate = (delegate as! BLEScanListEvent)
            navigationController?.pushViewController(scannerList, animated: true)
        }
         */
        
        if indexPath.section == 4
        {
            if !selectedCardArray.contains(indexPath)
            {
                selectedCardArray.append(indexPath)
            }
            else
            {
                
                if let index = selectedCardArray.firstIndex(of: indexPath) {
                    selectedCardArray.remove(at: index)
                }
            }
            

            //[self getCardType];
        }
        if(indexPath.section == 5)
        {
            if( ( optionDict["QuickChip"])?.intValue == 0 )
            {
                optionDict["QuickChip"] = NSNumber(value: 1)
            }
            else
            {
                optionDict["QuickChip"] = NSNumber(value: 0)
            }

        }
        if(indexPath.section == 6)
        {
            if (delegate?.responds(to: #selector(eDynamoController.didSelectConfigCommand(_:))))! {

            }
            if ((self.delegate?.responds(to: #selector(eDynamoController.didSelectSetDateTime)))!)
            {
                if indexPath.row == 0
                {
                    self.delegate?.didSelectSetDateTime?()
                }
            }

            
        }
        

        tableView.reloadData()
        if indexPath.section != 4
        {
        tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    func getCardType() -> UInt8
    {
        var selectedCard : UInt8 = 0
        var cardValue : UInt8 = 0
        
        for i in 0..<selectedCardArray.count {
            let indexPath = selectedCardArray[i]
            if indexPath.row == 0 {
                cardValue = 0x01
            } else if indexPath.row == 1 {
                cardValue = 0x02
            } else if indexPath.row == 2 {
                cardValue = 0x04
            }
            selectedCard = selectedCard | cardValue
        }
        
        return selectedCard
    }

    
    
    func getReportingOption() -> UInt8 {
        switch optionDict["ReportingOption"]?.intValue ?? 0 {
        case 0:
            return 0x00
        case 1:
            return 0x01
        case 2:
            return 0x02
        default:
            break
        }
        return 0x00
        
    }
    
    func getPurchaseOption() -> UInt8 {
        switch optionDict["PurchaseOption"]?.intValue ?? 0 {
        case 0:
            return 0x00
        case 1:
            return 0x02
        case 2:
            return 0x04
        case 3:
            return 0x08
        case 4:
            return 0x10
        case 5:
            return 0x40
        case 6:
            return 0x80
        default:
            break
        }
        return 0x00
    }
    
    func shouldSendApprove() -> Bool {
        if ( optionDict["ApproveSelection"] as? NSNumber)?.intValue ?? 0 == 0 {
            return true
        } else {
            return false
        }
    }

    func isQuickChip() -> Bool {
        if ( optionDict["QuickChip"] as? NSNumber)?.intValue == 0 {
            return false
        } else {
            return true
        }
    }
    
}
