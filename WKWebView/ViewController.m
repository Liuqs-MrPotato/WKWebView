//
//  ViewController.m
//  WKWebView
//
//  Created by 刘全水 on 16/6/17.
//  Copyright © 2016年 刘全水. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

#define ColorRGB(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define DiyBlueColor  ColorRGB(44, 133, 255)
#define DiyGray  ColorRGB(226, 226, 226)
#define Width CGRectGetWidth(self.view.bounds)
#define Height CGRectGetHeight(self.view.bounds)

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,UITextFieldDelegate>

@property (nonatomic, strong)WKWebView *webView;

@property (nonatomic, strong)UIProgressView *progressView;

@property (nonatomic, strong)UIButton *pageTitle;

@property (nonatomic, strong)UIButton *backBtn;

@property (nonatomic, strong)UIButton *stopBtn;

@property (nonatomic, strong)UITextField *linkField;

@property (nonatomic, strong)UIButton *cancelBtn;

@property (nonatomic, strong)CABasicAnimation *rotationAnimation;

@property (nonatomic, strong)UIButton *homeBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatNavBar];
    [self creatBottomBar];
    [self creatWebView];
    [self addobservers];
    [self addActions];
    [self creatAnimations];
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (void)creatNavBar {

    UIView *tooBar = [[UIView alloc]initWithFrame:CGRectMake(0, 20, Width, 44)];
    tooBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tooBar];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, Width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [tooBar addSubview:lineView];
    [tooBar addSubview:self.progressView];
    [tooBar addSubview:self.pageTitle];
    [tooBar addSubview:self.linkField];
    [tooBar addSubview:self.cancelBtn];
}

- (void)creatBottomBar {

    UIToolbar *BottomBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, Height - 44, Width, 44)];
    BottomBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:BottomBar];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [BottomBar addSubview:lineView];
    [BottomBar addSubview:self.backBtn];
    [BottomBar addSubview:self.stopBtn];
    [BottomBar addSubview:self.homeBtn];
}

- (void)creatWebView {

    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 64, Width, Height - 108)];
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    webView.allowsBackForwardNavigationGestures = YES;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    //3Dtouch预览链接（设备不支持会崩溃）
//    webView.allowsLinkPreview = YES;
    self.webView = webView;
}

- (void)addobservers {

    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)addActions {

    [self.backBtn     addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.stopBtn     addTarget:self action:@selector(changeLoadingMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.pageTitle   addTarget:self action:@selector(inputLink:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn   addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.homeBtn     addTarget:self action:@selector(backToHome) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backToHome {

   [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

- (void)creatAnimations {

    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.7;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100;
    self.rotationAnimation = rotationAnimation;
}

- (void)startAnimation {

    [self.stopBtn.layer addAnimation:_rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimations {

    [self.stopBtn.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)cancel:(UIButton *)cancelBtn {

    [UIView animateWithDuration:0.25 animations:^{
        
        cancelBtn.alpha = 0;
        [self.linkField resignFirstResponder];
    }];
    
}

- (void)inputLink:(UIButton *)inputBtn {

    [UIView animateWithDuration:0.25 animations:^{
     
        inputBtn.alpha = 0;
        self.linkField.alpha = 1;
        self.cancelBtn.alpha = 1;
        [self.linkField becomeFirstResponder];
        [self.linkField selectAll:nil];
    }];
    
}

- (void)changeLoadingMode:(UIButton *)stopBtn {

    [self.webView reload];
}

- (void)back {

    [self.webView goBack];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {

    if ([keyPath isEqualToString:@"loading"]) {
        
        [self startAnimation];
        NSLog(@"加载中");
        
    }else if ([keyPath isEqualToString:@"title"]){
        
        [self.pageTitle setTitle:self.webView.title forState:UIControlStateNormal];
        
    }else if ([keyPath isEqualToString:@"estimatedProgress"]) {
    
        self.progressView.progress = self.webView.estimatedProgress;
        
            if (self.progressView.progress >= 1.0) {
               self.progressView.hidden = YES;
               self.progressView.progress = 0.0;
            }else {
              self.progressView.hidden = NO;
            }
        
    }else if ([keyPath isEqualToString:@"URL"]) {
    
        NSLog(@"%@",self.webView.URL.host.lowercaseString);
        self.linkField.text = self.webView.URL.absoluteString;
        
    }else {}
    
    if (!self.webView.isLoading) {
        
        [self stopAnimations];
        NSLog(@"加载停止（失败或者加载完成）");
    }
    
}


- (void)dealloc {

    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"URL"];
}

#pragma mark - WKNavigationDelegate 方法

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    NSLog(@"%@",error.debugDescription);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加载失败" message:@"要不，稍后再试试？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{

    NSLog(@"%@",error.debugDescription);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    decisionHandler(WKNavigationActionPolicyAllow);
    [self.linkField resignFirstResponder];

}


#pragma mark - WKUIDelegate 方法
//监听web的alert可以转原生提示
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    completionHandler();
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.webView.title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSLog(@"点击了alert");
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - UITextFieldDelegate 方法

- (void)textFieldDidEndEditing:(UITextField *)textField {

    [UIView animateWithDuration:0.25 animations:^{
        self.pageTitle.alpha = 1.0;
        self.linkField.alpha = 0.0;
        self.cancelBtn.alpha = 0.0;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSString *urlStr = [self changeStringWithString:self.linkField.text];
    NSString *encodeUrlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodeUrlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    return YES;
}

- (NSString *)changeStringWithString:(NSString *)urlStr {

    NSString *newUrlStr;
    NSString *subString = [urlStr substringWithRange:NSMakeRange(0, 4)];
    if (![subString isEqualToString:@"http"] && ![subString isEqualToString:@"HTTP"]) {
        
        newUrlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    
    return newUrlStr;
}

#pragma mark --- 控件

- (UIButton *)homeBtn {

    if (!_homeBtn) {
        _homeBtn = [[UIButton alloc]initWithFrame:CGRectMake((Width - 44) / 2, 0, 44, 44)];
        [_homeBtn setImage:[UIImage imageNamed:@"home"] forState:UIControlStateNormal];
        [_homeBtn setImage:[UIImage imageNamed:@"home-click"] forState:UIControlStateHighlighted];
    }
    return _homeBtn;
}

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 44, 0, 44, 44)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelBtn.alpha = 0;
        
    }
    return _cancelBtn;
}


- (UITextField *)linkField {
    
    if (!_linkField) {
        _linkField = [[UITextField alloc]initWithFrame:CGRectMake(20, 8, Width - 64, 28)];
        _linkField.layer.cornerRadius = 4;
        _linkField.layer.masksToBounds = YES;
        _linkField.textAlignment = NSTextAlignmentCenter;
        _linkField.font = [UIFont systemFontOfSize:17];
        _linkField.backgroundColor = DiyGray;
        _linkField.returnKeyType = UIReturnKeyGo;
        _linkField.delegate = self;
        _linkField.textColor = [UIColor blackColor];
        _linkField.alpha = 0;
    }
    return _linkField;
}

- (UIButton *)stopBtn {
    
    if (!_stopBtn) {
        _stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(Width - 54, 0, 44, 44)];
        [_stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [_stopBtn setImage:[UIImage imageNamed:@"refresh_click"] forState:UIControlStateHighlighted];
    }
    return _stopBtn;
}

-(UIButton *)backBtn {
    
    if (!_backBtn) {
        _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 0, 44, 44)];
        [_backBtn setImage:[UIImage imageNamed:@"chapterBackBtn"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"chapterBackBtnSelected"] forState:UIControlStateHighlighted];
        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIButton *)pageTitle {
    
    if (!_pageTitle) {
        _pageTitle = [[UIButton alloc]initWithFrame:CGRectMake(20, 12, Width - 40, 20)];
        _pageTitle.backgroundColor = [UIColor clearColor];
        _pageTitle.layer.cornerRadius = 4;
        _pageTitle.titleLabel.font = [UIFont systemFontOfSize:17];
        [_pageTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _pageTitle.layer.masksToBounds = YES;
    }
    return _pageTitle;
}

-(UIProgressView *)progressView {
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = DiyBlueColor;
        _progressView.transform = CGAffineTransformMakeScale(1.0f,1.0f);
        _progressView.frame = CGRectMake(0, 42.5, Width, 1);
    }
    return _progressView;
    
}

@end
