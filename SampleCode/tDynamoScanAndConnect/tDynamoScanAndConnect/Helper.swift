//
//  Helper.swift
//  iDynamo6Swift
//
//  Created by Yong Guo on 7/28/21.
//

import Foundation

class Helper {
    
    static func StringToN12(v : String)-> NSData {
        let amount = Double(v)
        let strAmount = String(format: "%12.0f", (amount ?? 0) * 100)
        let dataAmount = HexUtil.getBytesFromHexString(strAmount)
        return dataAmount ?? NSData()
    }
    
    static func buildSetDateTimeCommand() -> String {
        let date = Date()
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from:date)-2008
        let month = calendar.component(.month, from:date)
        let day = calendar.component(.day, from:date)
        let hour = calendar.component(.hour, from:date)
        let minute = calendar.component(.minute, from:date)
        let second = calendar.component(.second, from:date)
        
        let cmd = "030C"
        let size = "0018"
        let deviceSn = "00000000000000000000000000000000"
        let strMonth = String(format: "%02lX", month)
        let strDay = String(format: "%02lX", day)
        let strHour = String(format: "%02lX", hour)
        let strMinute = String(format: "%02lX", minute)
        let strSecond = String(format: "%02lX", second)
        let strYear = String(format: "%02lX", year)
        let commandToSend = "\(cmd)\(size)00\(deviceSn)\(strMonth)\(strDay)\(strHour)\(strMinute)\(strSecond)00\(strYear)"
        
        return commandToSend
    }
    
    static func buildAcquirerResponse(_ deviceSN: Data,  encryptionType: Data,ksn: Data, approved: Bool) ->Data
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

            len += encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count;
        
        var len1 = (UInt8)((len >> 8) & 0xff);
        var len2 = (UInt8)(len & 0xff);
        
        var tempByte = 0xf9;
        response.append(&len1, length: 1)
        response.append(&len2, length: 1)
        response.append(&tempByte, length: 1)
        tempByte = (len - 2)

            tempByte = encryptionTypeTag.count + encryptionType.count + ksnTag.count + ksn.count +  snTag.count + lenSN + container.count + approvedARC.count;
            
        response.append(&tempByte, length: 1)

            response.append(ksnTag);
            response.append(ksn);
            response.append(encryptionTypeTag);
            response.append(encryptionType);
        
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
        
            response.append(Data(fromArray: macPadding))
        
        return response as Data;
        
    }

    static func buildARPCfromARQC(arqc data: Data, approve : Bool) -> [UInt8] {
        let tlv = NSData(data: data).parseTLVData()
        
        var snStr = ""
        if let tempTLVObj = tlv?["DFDF25"] as? MTTLV
        {
            snStr = tempTLVObj.value
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
                    
        let response = Helper.buildAcquirerResponse(
            HexUtil.getBytesFromHexString(snStr)! as Data, encryptionType: HexUtil.getBytesFromHexString(dfdf55Str)! as Data, ksn: HexUtil.getBytesFromHexString(dfdf54Str)! as Data, approved: true)
        var responseData : [UInt8] = Array.init(repeating: 0, count: response.count)
        response.copyBytes(to: &responseData, count: response.count)

        return responseData
    }
}
