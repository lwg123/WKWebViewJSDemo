//
//  ViewController.m
//  WKWebViewJSDemo
//
//  Created by weiguang on 2018/7/5.
//  Copyright © 2018年 weiguang. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define KMainWidth ([UIScreen mainScreen].bounds.size.width)
#define KMainHeight ([UIScreen mainScreen].bounds.size.height)


@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *mainWebView;

@property (nonatomic, strong) UIButton *alertBtn;

@end

@implementation ViewController



#pragma mark -  view 加载完成
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.view addSubview:self.mainWebView];
    [self.view addSubview:self.alertBtn];
    self.view.backgroundColor = [UIColor whiteColor];
    
}


#pragma mark -  懒加载WKWebView和button
- (WKWebView *)mainWebView {
    if (_mainWebView == nil) {
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        configuration.userContentController = userController;
        
        _mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, KMainWidth, KMainHeight) configuration:configuration];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
        [_mainWebView loadRequest:request];
        
        //[_mainWebView loadFileURL:[NSURL fileURLWithPath:path] allowingReadAccessToURL:[NSURL fileURLWithPath:path]];
        
        _mainWebView.navigationDelegate = self;
        _mainWebView.UIDelegate = self;
        [userController addScriptMessageHandler:self name:@"currentCookies"];
    }
    
    return _mainWebView;
}

- (UIButton *)alertBtn {
    if (_alertBtn == nil) {
        _alertBtn = [[UIButton alloc] initWithFrame:CGRectMake(KMainWidth*0.2, KMainHeight - 60, KMainWidth * 0.6, 40)];
        _alertBtn.backgroundColor = [UIColor blueColor];
        _alertBtn.layer.cornerRadius = 6.0f;
        _alertBtn.layer.masksToBounds = YES;
        _alertBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_alertBtn setTitle:@"弹出弹窗" forState:UIControlStateNormal];
        [_alertBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_alertBtn addTarget:self action:@selector(alertButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _alertBtn;
}

- (void)alertButtonAction {
    [self.mainWebView evaluateJavaScript:@"alertAction('OC调用JS警告窗方法')" completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        NSLog(@"完成OC 调用js");
    }];
}

#pragma mark -  <WKScriptMessageHandler>
//JS调用的OC回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"currentCookies"]) {
        NSString *cookiesStr = message.body;
        NSLog(@"当前的cookie为： %@", cookiesStr);
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"JS调用的OC回调方法" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleCancel) handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

//接收到警告面板
#pragma mark -  <WKUIDelegate>
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(); //此处的completionHandler()就是调用JS方法时，`evaluateJavaScript`方法中的completionHandler
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

//接收到确认面板
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"收到确认面板");
}

//接收到输入框
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSLog(@"收到输入框");
}

- (void)dealloc{
    
    [self.mainWebView.configuration.userContentController removeScriptMessageHandlerForName:@"currentCookies"];
}

@end
