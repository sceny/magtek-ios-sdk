//
//  eDynamoSignature.swift
//  MTSCRADemo-Swift
//
//  Created by Ramu Guttula on 07/08/19.
//  Copyright © 2019 MagTek. All rights reserved.
//

import UIKit

class eDynamoSignature: UIViewController {

    var mouseSwiped = false
    
    var drawImage: UIImageView?
    
    var lastPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        drawImage = UIImageView(frame: view.bounds)
        drawImage?.image = UIImage()
        view.addSubview(drawImage!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        mouseSwiped = false
        let touch = touches.first
        
        if touch?.tapCount == 2 {
            drawImage!.image = nil
            return
        }
        
        lastPoint = (touch?.location(in: view))!
        //lastPoint.y -= 20;
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseSwiped = true
        
        let touch = touches.first
        let currentPoint = touch?.location(in: view)
        //currentPoint.y -= 20;
        UIGraphicsBeginImageContextWithOptions(view.frame.size, _: false, _: UIScreen.main.scale)
        drawImage!.image!.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        UIGraphicsGetCurrentContext()!.setLineCap(CGLineCap.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(5.0)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        UIGraphicsGetCurrentContext()?.beginPath()
        UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
        UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint?.x ?? 0.0, y: currentPoint?.y ?? 0.0))
        UIGraphicsGetCurrentContext()?.strokePath()
        drawImage!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lastPoint = currentPoint!
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        
        if touch?.tapCount == 2 {
            drawImage?.image = nil
            return
        }
        
        
        if !mouseSwiped {
            
            UIGraphicsBeginImageContextWithOptions(view.frame.size, _: false, _: UIScreen.main.scale)
            drawImage?.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(5.0)
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            UIGraphicsGetCurrentContext()!.flush()
            drawImage?.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }

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
