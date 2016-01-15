//
//  ViewController.h
//  SocketServer
//
//  Created by 洪新建 on 16/1/9.
//  Copyright © 2016年 洪新建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"

@interface ViewController : UIViewController <UITextFieldDelegate, AsyncSocketDelegate> {
    AsyncSocket *listener;              // 设置监听器
    NSMutableArray *connectionSockets;   // 当前请求客户端
    
    IBOutlet UITextField *message;
    IBOutlet UITextView *receiveData;
}

@property (nonatomic, retain)AsyncSocket *listener;
@property (nonatomic, retain)UITextField *message;
@property (nonatomic, retain)UITextView *receiveData;

- (IBAction)sendMessage:(id)sender;
- (IBAction)textEndEditing:(id)sender;


@end

