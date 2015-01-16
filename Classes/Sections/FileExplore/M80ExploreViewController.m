//
//  M80ExploreViewController.m
//  M80WifiSync
//
//  Created by amao on 1/16/15.
//  Copyright (c) 2015 www.xiangwangfeng.com. All rights reserved.
//

#import "M80ExploreViewController.h"
@import QuickLook;
@import MediaPlayer;

@interface M80ImageViewController : M80ExploreViewController
@end
@interface M80VideoViewController : M80ExploreViewController
@property (nonatomic,strong)    MPMoviePlayerController *mediaPlayer;
@end
@interface M80FileExploreViewController : M80ExploreViewController<QLPreviewControllerDataSource>
@end

@interface M80ExploreViewController ()
@property (nonatomic,copy)    NSString    *filepath;
@end

@implementation M80ExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(onShare:)];
    
    self.navigationItem.rightBarButtonItem = right;
}



- (void)onShare:(id)sender
{
    [self fireActions];
}

+ (NSString *)vcClassName:(NSString *)ext
{
    static NSDictionary *classDict = nil;
    if (classDict == nil)
    {
        classDict = @{@"png"        : @"M80ImageViewController",
                      @"jpeg"       : @"M80ImageViewController",
                      @"jpg"        : @"M80ImageViewController",
                      @"gif"        : @"M80ImageViewController",
                      
                      @"mp4"        : @"M80VideoViewController",
                      @"3gp"        : @"M80VideoViewController",
                      @"mov"        : @"M80VideoViewController",
                      @"m4v"        : @"M80VideoViewController",};
    }
    return [classDict objectForKey:ext];
}


+ (instancetype)exploreViewController:(NSString *)filepath
{
    M80ExploreViewController *vc = nil;
    NSString *ext = [[filepath pathExtension] lowercaseString];
    NSString *className = [self vcClassName:ext];
    if (className)
    {
        vc = [[NSClassFromString(className) alloc] init];
    }
    else
    {
        vc = [[M80FileExploreViewController alloc] init];
    }
    vc.filepath = filepath;
    return vc;
}

#pragma mark - 操作
- (void)fireActions
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"文件操作", nil)
                                                                message:NSLocalizedString(@"", nil)
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"保存到相册", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           [self saveToAlbum];
                                                       }];
    [vc addAction:saveAction];
    
    UIAlertAction *wexinAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"发送图片到微信", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self shareToWX];
                                                            
                                                        }];
    [vc addAction:wexinAction];
    
    UIAlertAction *emoticonAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"发送表情到微信", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [self shareEmoticonToWX];
                                                           }];
    [vc addAction:emoticonAction];
    
    UIAlertAction *yixinAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"发送图片到易信", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [self shareToYX];
                                                           }];
    [vc addAction:yixinAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [vc addAction:cancelAction];
    
    
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
}

- (void)saveToAlbum
{
    UIImage *image = [UIImage imageWithContentsOfFile:self.filepath];
    if (image)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        return;
    }
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.filepath))
    {
        UISaveVideoAtPathToSavedPhotosAlbum(self.filepath, self, nil, nil);
        return;
    }

    
    
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *) error
  contextInfo:(void *)contextInfo
{
    
}

- (void)video:(NSString *)videoPath
didFinishSavingWithError:(NSError *) error
  contextInfo:(void *)contextInfo
{

}

- (void)shareToWX
{

}

- (void)shareToYX
{

}

- (void)shareEmoticonToWX
{

}
@end


#pragma mark - 图片预览
@implementation M80ImageViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageWithContentsOfFile:self.filepath];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:imageView];
}

- (BOOL)isFileImage
{
    return YES;
}
@end


#pragma mark - 视频预览
@implementation M80VideoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *url = [NSURL fileURLWithPath:self.filepath];
    _mediaPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.view addSubview:_mediaPlayer.view];
    [_mediaPlayer.view setFrame:self.view.bounds];
    [_mediaPlayer.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_mediaPlayer play];
}

- (BOOL)isFileVideo
{
    return YES;
}

@end

#pragma mark - 文件预览
@implementation M80FileExploreViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:self.filepath];
    
    if ([QLPreviewController canPreviewItem:url])
    {
        [self addQLPreview];
    }
    else
    {
        [self addErrorTip];
    }
}

- (void)addQLPreview
{
    QLPreviewController *vc = [[QLPreviewController alloc] init];
    vc.dataSource = self;
    [self addChildViewController:vc];
    [vc.view setFrame:self.view.bounds];
    [vc.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:vc.view];
}

- (void)addErrorTip
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"不支持的文件类型", nil)
                                                                        message:NSLocalizedString(@"当前文件展示不支持预览", nil)
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:controller
                       animated:YES
                     completion:nil];
                                    
}

#pragma mark - QL
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:self.filepath];
}

@end