//
//  ViewController.m
//  SocketServer
//
//  Created by 洪新建 on 16/1/9.
//  Copyright © 2016年 洪新建. All rights reserved.
//

#import "ViewController.h"
#import "Config.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize listener, message, receiveData;
bool isRunning = NO;                        // 判断是否开始监听

-(void) sendMessage {
    
    if (!isRunning) {
        
        NSError *error = nil;
        if (![listener acceptOnPort:_SERVER_PORT_ error:&error]) {
            return;
        }
        NSLog(@"开始监听");
        isRunning = YES;
    } else {
        
        NSLog(@"重新监听");
        [listener disconnect];
        for (int i = 0; i < [connectionSockets count]; i++) {
            [[connectionSockets objectAtIndex:i] disconnect];
        }
        isRunning = FALSE;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    if (![message.text isEqualToString:@""]) {
        [listener writeData:[message.text dataUsingEncoding:NSUTF8StringEncoding]
                withTimeout:-1 tag:1];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"请输入消息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(IBAction)textEndEditing:(id)sender {
    [message resignFirstResponder];
}

- (void)viewDidLoad {
    receiveData.editable = NO;
    listener = [[AsyncSocket alloc]initWithDelegate:self];
    message.delegate = self;
    connectionSockets = [[NSMutableArray alloc] initWithCapacity:30];
    [self sendMessage];
    [super viewDidLoad];
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma socket
-(void) onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    NSLog(@"%@", [err description]);
}

-(void) onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
    [connectionSockets addObject:newSocket];
}

-(void) onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [sock readDataWithTimeout:-1 tag:0];
}

-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"host:%@", host);
    NSString *returnMessage = @"Welcome To Socket Test Server!";
    NSData *data = [returnMessage dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:-1 tag:0];
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *recieveIP = nil;
    for (int i = 0; i < [connectionSockets count]; i++) {
        AsyncSocket *s = (AsyncSocket *)[connectionSockets objectAtIndex:i];
        if ([sock.connectedHost isEqualToString:@"172.20.10.4"]) {
            recieveIP = @"172.20.10.1";
        } else {
            recieveIP = @"172.20.10.4";
        }
        
        if (![s.connectedHost isEqualToString:recieveIP]) {
            
            if (![msg isEqualToString:@"connect id hear"]) {
                [s writeData:data withTimeout:-1 tag:0];
                receiveData.text = msg;
                NSLog(@"message-->%@收到%@-->%@", sock.connectedHost, recieveIP, msg);
            } else {
                [s writeData:data withTimeout:-1 tag:1];
            }
        } else {
            [s writeData:data withTimeout:-1 tag:1];
            NSLog(@"积极 : %@",msg);
        }
    }
}

-(void) onSocketDidDisconnect:(AsyncSocket *)sock {
    [connectionSockets removeObject:sock];
}

- (void)dealloc
{
    [receiveData release], receiveData=nil;
    [message release], message=nil;
    [listener release];
    [receiveData release];
    [super dealloc];
}

@end
