//
//  MTSCRADemoTests.m
//  MTSCRADemoTests
//
//  Created by Tam Nguyen on 7/21/15.
//  Copyright (c) 2015 MagTek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MTDataViewerViewController.h"
#import "AppDelegate.h"
#import "kDynamoController.h"
#import "MTSCRA.h"


@interface MTSCRADemoTests : XCTestCase<MTSCRAEventDelegate>

@end

@interface MTSCRADemoTests()

@end

@implementation MTSCRADemoTests

- (void)onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance
{
    
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConnectDisconnect {
    MTSCRA* lib = [MTSCRA new];

    [lib setConnectionType :  Lightning ];
    [lib setDeviceType:(UInt32)MAGTEKKDYNAMO];
    [lib setDeviceProtocolString :@"com.magtek.idynamo"];
    [lib setDebugInfoCallback:^(MTDebugInfo* info){}];
        
    [lib openDeviceSync];

    NSString* response1 = [lib sendCommandSync:@"480100"];
    NSLog(@"%@ -> %@", @"480100", response1);
    XCTAssert([response1 length] > 0, @"PASS 480100");
    NSString* response2 = [lib sendCommandSync:@"000103"];
    NSLog(@"%@ -> %@", @"000103", response2);
    XCTAssert([response2 length] > 0, @"PASS 000103");
    [lib closeDeviceSync];
}


- (void)testGetFirmwarePartNumber {
    MTSCRA* lib = [MTSCRA new];

    [lib setConnectionType :  Lightning ];
    [lib setDeviceType:(UInt32)MAGTEKKDYNAMO];
    [lib setDeviceProtocolString :@"com.magtek.idynamo"];
    [lib setDebugInfoCallback:^(MTDebugInfo* info){}];
        
    [lib openDeviceSync];

    NSString* response1 = [lib getFirmware];

    XCTAssert([response1 length] > 0, @"PASS 000103");
    
    NSString* sn = [lib getDeviceSerial];
    XCTAssert(sn.length > 0, @"PASS SN");
    [lib closeDeviceSync];
}


- (void)testConnectDisconnectExtendedCommand {
    MTSCRA* lib = [MTSCRA new];

    [lib setConnectionType :  Lightning ];
    [lib setDeviceType:(UInt32)MAGTEKKDYNAMO];
    [lib setDeviceProtocolString :@"com.magtek.idynamo"];
    [lib setDebugInfoCallback:^(MTDebugInfo* info){}];
        
    [lib openDeviceSync];

    NSString* response1 = [lib sendCommandSync:@"480100"];
    NSLog(@"%@ -> %@", @"480100", response1);
    XCTAssert([response1 length] > 0, @"PASS 480100");
    NSString* response2 = [lib sendCommandSync:@"000103"];
    NSLog(@"%@ -> %@", @"000103", response2);
    XCTAssert([response2 length] > 0, @"PASS 480100");
    NSString* response3 = [lib sendExtendedCommandSync:@"0311000100"];
    NSLog(@"%@ -> %@", @"0311000100", response3);
    XCTAssert([response3 length] > 0, @"PASS 0311000100");
    [lib closeDeviceSync];
}


- (void)testConnectDisconnectExtendedCommand1000 {
    MTSCRA* lib = [MTSCRA new];

    for (int i = 0; i < 1000; i ++)
    {
        [lib setConnectionType :  Lightning ];
        [lib setDeviceType:(UInt32)MAGTEKKDYNAMO];
        [lib setDeviceProtocolString :@"com.magtek.idynamo"];
        [lib setDebugInfoCallback:^(MTDebugInfo* info){}];
            
        [lib openDeviceSync];
        NSString* response1 = [lib sendCommandSync:@"480100"];
        NSLog(@"%@ -> %@", @"480100", response1);
        XCTAssert([response1 length] > 0, @"PASS 480100");
        NSString* response2 = [lib sendCommandSync:@"000103"];
        NSLog(@"%@ -> %@", @"000103", response2);
        XCTAssert([response2 length] > 0, @"PASS 480100");
        NSString* response3 = [lib sendExtendedCommandSync:@"0311000100"];
        NSLog(@"%@ -> %@", @"0311000100", response3);
        XCTAssert([response3 length] > 0, @"PASS 0311000100");
        [lib closeDeviceSync];
    }
}


- (void)testConnectDisconnect1000 {
    MTSCRA* lib = [MTSCRA new];

    for (int i = 0; i < 1000; i ++)
    {
        NSLog(@"Loop %d", i);
        [lib setConnectionType :  Lightning ];
        [lib setDeviceType:(UInt32)MAGTEKKDYNAMO];
        [lib setDeviceProtocolString :@"com.magtek.idynamo"];
        [lib setDebugInfoCallback:^(MTDebugInfo* info){}];
            
        [lib openDeviceSync];
        NSString* response1 = [lib sendCommandSync:@"480100"];
        NSLog(@"%@ -> %@", @"480100", response1);
        XCTAssert([response1 length] > 0, @"PASS 480100");
        NSString* response2 = [lib sendCommandSync:@"000103"];
        NSLog(@"%@ -> %@", @"000103", response2);
        XCTAssert([response2 length] > 0, @"PASS 000103");
        [lib closeDeviceSync];
    }
}


- (void)testExample {
    // This is an example of a functional test case.
    UIApplication* app = [UIApplication sharedApplication];
    UITabBarController* tab = (UITabBarController*)app.keyWindow.rootViewController;
    [tab setSelectedIndex:1];
    UINavigationController* kNav =  tab.viewControllers[1];
    kDynamoController* kDynamo = kNav.viewControllers[0];
    
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];
    [kDynamo connect];

    
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}



int DecodeRLEData(unsigned char * pubEncodedData, int iDataLen, unsigned char * pubDecodedData, unsigned long *pDecodeDataLen)
{
    
    unsigned char     pubDecodedDataLocal[4096];
    unsigned char*    pubCurrent              = pubEncodedData;
    unsigned char*    pubLast                 = (pubEncodedData + iDataLen);
    unsigned long     decodedDataLen          = 0;
    int               repeatedDataLen   = 0;
    
    
    //memset(pubDecodedDataLocal, 0x00, iDataLen);
    //memcpy(pubEncodedDataLocal, pubEncodedData, iDataLen);
    
    unsigned long wantedLength = *pDecodeDataLen;

    @try
    {
        while (pubCurrent < pubLast)
        {
           // NSLog(@"%02x", *pubCurrent);
            if ( ((pubCurrent+1) < pubLast) && ( *pubCurrent == *(pubCurrent+1)))
            {
                if ((pubCurrent + 2) < pubLast)
                {
                    repeatedDataLen = *(pubCurrent + 2);
                    for (int k = 0; k < repeatedDataLen; k++)
                    {
                        pubDecodedDataLocal[decodedDataLen++] = *pubCurrent;
                    }
                    pubCurrent += 3;
                }
                else
                {
                    return 2;
                }
            }
            else
            {
                pubDecodedDataLocal[decodedDataLen++] = *pubCurrent;
                ++pubCurrent;
            }
        }
    }
    @catch(NSException* ex)
    {
        return -1;
    }
    
//    if (decodedDataLen > wantedLength)
//        decodedDataLen = wantedLength; // limited the output
    
    *pDecodeDataLen = decodedDataLen;
    memcpy(pubDecodedData, pubDecodedDataLocal,decodedDataLen);
    
    NSLog(@"Decode RLE - Wanted = %lu, Length = %lu", wantedLength, decodedDataLen);
    
    return 0;
}

+ (NSData *) dataFromHexString:(NSString*)hexString
{
    NSString * cleanString = hexString;
    
    NSMutableData *result = [[NSMutableData alloc] init];
    
    int i = 0;
    for (i = 0; i+2 <= cleanString.length; i+=2) {
        NSRange range = NSMakeRange(i, 2);
        NSString* hexStr = [cleanString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        unsigned char uc = (unsigned char) intValue;
        [result appendBytes:&uc length:1];
    }
    NSData * data = [NSData dataWithData:result];

    return data;
}

+ (NSString *)getHexString:(NSData *)data
{
    
    
    NSMutableString *mutableStringTemp = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < data.length; i++)
    {
        unsigned char tempByte;
        
        [data getBytes:&tempByte
                 range:NSMakeRange(i, 1)];
        
        [mutableStringTemp appendFormat:@"%02X", tempByte];
    }
    
    return mutableStringTemp;
}

- (void) testRLEDecode
{
    NSString* hex = @"0000034828000002F745BB4793922D09C901984C22D2FF6841B67832AF824C386DFC0AF0B1AE5D3C3BD1DBC05201CA487E35D5DB30BA9E56407548F07CDB1CCB57495F1619F260F5B6DA59F0F13995160000286DDAB3A332BA9EC53E43AD01721998C2C4F9C604772E6AEF60D609BC7ED9A9D09B02270DDE7B2A900000B96140020038E1D7E3ED7CBD7DD7E2D0F9A24E7125E30E1738BFDC8483718A687310B01672FD6FE14C99B088DD558CB7BC6BEC6FD4BDED17A9678CF17C8000004842353146344544313032373231414102000002069011880B51F4ED0000021C442700254234313103303004313030033131045E564953412F4155544F4D4154494F4E205E333031323130313030183F00002C3B34313103303004313030033131043D3330313231303130300D3F0000B9625A7C9BC916195B4427007000134200035630354431303237323141410200FFFF0300000A0300001F9011880B51F4ED0000021C0058FF06";
    
    NSData* data = [MTSCRADemoTests dataFromHexString:hex];

    unsigned char buffer[2048];
    unsigned long length = 2048;
    
    DecodeRLEData([data bytes], data.length, buffer, &length);
    
    NSData* decodedData = [NSData dataWithBytes:buffer length:length];
    
    NSString* hexData = [MTSCRADemoTests getHexString:decodedData];
    
    NSLog(@"%@", hexData);
    
    assert(length == 932);
}


@end
