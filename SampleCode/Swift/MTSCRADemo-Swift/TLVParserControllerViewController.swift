//
//  TLVParserControllerViewController.swift
//  MTSCRADemo-Swift
//
//  Created by Ramu Guttula on 12/08/19.
//  Copyright © 2019 MagTek. All rights reserved.
//

import UIKit

class TLVParserControllerViewController: MTDataViewerViewController {
    
    var parseTLV:UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TLV Parser"
        self.txtData?.isEditable = true
        self.txtData?.delegate = self
        
        self.view.backgroundColor = .white
        
        self.txtCommand?.isHidden = true
        self.btnSendCommand?.isHidden = true
        self.btnConnect?.isHidden = true
        self.parseTLV = UIButton(frame: self.btnConnect!.frame)
        self.parseTLV!.setTitle("Parse TLV", for: .normal)
        self.parseTLV!.backgroundColor = UIColor(hex: 0x3465AA)
        self.parseTLV!.addTarget(self, action: #selector(parseTLVInfo), for: .touchUpInside)
        view.addSubview(self.parseTLV!)
        if UIDevice.current.userInterfaceIdiom == .phone {
            let navHeight = Int((navigationController?.navigationBar.frame.size.height ?? 0.0) + UIApplication.shared.statusBarFrame.size.height)
            self.txtData!.frame = txtData!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
            self.parseTLV!.frame = self.parseTLV!.frame.offsetBy(dx: 0, dy: CGFloat(navHeight))
        }
    }
    @objc func parseTLVInfo() {
            if self.txtData!.text.count < 2 {
                return
            }
        self.txtData?.text = self.txtData?.text.uppercased()
        if let indexVal = self.txtData?.text.indexDistance(of: "F9")
       {

        let dataString = (self.txtData!.text as NSString?)?.substring(from: indexVal)
        let emvBytes = HexUtil.getBytesFromHexString(dataString!)
        let tlv = emvBytes?.parseTLVDataWithNoLength()
        self.txtData!.text = tlv?.dumpTags()
         self.scrollTextView(toBottom: self.txtData)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let xOffset = (self.navigationController?.navigationBar.frame.size.height ?? 0) + (self.tabBarController?.tabBar.frame.size.height ?? 0) + UIApplication.shared.statusBarFrame.size.height;
        
        self.txtData?.frame  = CGRect(x: 5, y: 60, width: size.width - 10 , height: size.height - 20 - xOffset)
        self.parseTLV?.frame = CGRect(x: 0, y: size.height - 65 - xOffset + 120, width: size.width, height: 50)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension TLVParserControllerViewController : UITextViewDelegate
{
//    @override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return true
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
        //return true
    }
}
