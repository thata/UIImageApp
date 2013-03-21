//
//  ViewController.m
//  UIImageApp
//
//  Created by thata on 2013/03/21.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "ViewController.h"
#import "jpeglib.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)copyImage:(id)sender {
    UIImage *src = _image1.image;
    _image2.image = [self convert:src];
}

- (IBAction)copyImage2:(id)sender {
    UIImage *image = _image1.image;
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;

//            // 色の取得 (0から255を0.0から1.0へ変換している)
//            CGFloat red = (rawData[byteIndex] * 1.0) / 255.0;
//            CGFloat green = (rawData[byteIndex + 1] * 1.0) / 255.0;
//            CGFloat blue = (rawData[byteIndex + 2] * 1.0) / 255.0;
//            CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;

            // グレイスケール化
            // 参考: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            unsigned char gray = rawData[byteIndex] * 0.3 + rawData[byteIndex + 1] * 0.59 + rawData[byteIndex + 2] * 0.11;
            rawData[byteIndex] = gray;
            rawData[byteIndex + 1] = gray;
            rawData[byteIndex + 2] = gray;
            
//            // 色を反転する
//            rawData[byteIndex] = 255 - rawData[byteIndex];
//            rawData[byteIndex + 1] = 255 - rawData[byteIndex + 1];
//            rawData[byteIndex + 2] = 255 - rawData[byteIndex + 2];
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:newImageRef];
    
    // we're done with image now too
    CGImageRelease(newImageRef);
    
//    return resultUIImage;
    _image2.image = resultUIImage;
}

typedef void(^ConverterBlock)(unsigned char *rawData, NSUInteger width, NSUInteger height, NSUInteger bytesPerPixcel, NSUInteger bytesPerRow);

- (UIImage *)convertImage:(UIImage *)image withBlock:(ConverterBlock)convert
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);

    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |
                                                 kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    convert(rawData, width, height, bytesPerPixel, bytesPerRow);
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:newImageRef];
    
    // we're done with image now too
    CGImageRelease(newImageRef);

    return resultUIImage;
}

- (IBAction)grayscaleImage:(id)sender {
    UIImage *image = _image1.image;
    _image2.image = [self convertImage:image
                             withBlock:^(unsigned char *rawData,
                                         NSUInteger width,
                                         NSUInteger height,
                                         NSUInteger bytesPerPixel,
                                         NSUInteger bytesPerRow) {
                                 for (int y = 0; y < height; y++) {
                                     for (int x = 0; x < width; x++) {
                                         int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
                                         // グレイスケール化
                                         // 参考: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
                                         unsigned char gray = rawData[byteIndex] * 0.3 + rawData[byteIndex + 1] * 0.59 + rawData[byteIndex + 2] * 0.11;
                                         rawData[byteIndex] = gray;
                                         rawData[byteIndex + 1] = gray;
                                         rawData[byteIndex + 2] = gray;
                                     }
                                 }
                             }];
}

- (IBAction)negativeImage:(id)sender {
    UIImage *image = _image1.image;
    _image2.image = [self convertImage:image
                             withBlock:^(unsigned char *rawData,
                                         NSUInteger width,
                                         NSUInteger height,
                                         NSUInteger bytesPerPixel,
                                         NSUInteger bytesPerRow) {
                                 for (int y = 0; y < height; y++) {
                                     for (int x = 0; x < width; x++) {
                                         int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
                                         // 色を反転する
                                         rawData[byteIndex] = 255 - rawData[byteIndex];
                                         rawData[byteIndex + 1] = 255 - rawData[byteIndex + 1];
                                         rawData[byteIndex + 2] = 255 - rawData[byteIndex + 2];
                                     }
                                 }
                             }];    
}

- (IBAction)grayscaleJpeg:(id)sender {
    UIImageWriteGrayscaleToDocuments(nil, @"test.jpg");

    // 書き込んだjpegファイルを取得
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:@"test.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    _image2.image = image;
}

- (UIImage *)convert:(UIImage *)src
{
    return src;
}

@end

void UIImageWriteGrayscaleToDocuments(UIImage *image, NSString *fileName)
{
    /* 画像のパラメータの設定 */
    int width = 256;
    int height = 256;
    
    /* JPEGオブジェクト, エラーハンドラの確保 */
    struct jpeg_compress_struct cinfo;
    struct jpeg_error_mgr jpeg_err;
    
    /* エラーハンドラにデフォルト値を設定 */
    cinfo.err = jpeg_std_error(&jpeg_err);
    
    /* JPEGオブジェクトの初期化 */
    jpeg_create_compress(&cinfo);
    
    /* 出力ファイルの設定 */
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
    NSString *path = [url path];
    const char *filename = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fp = fopen(filename, "wb");
    if (fp == NULL) {
        fprintf(stderr, "cannot open %s\n", filename);
        exit(EXIT_FAILURE);
    }
    jpeg_stdio_dest(&cinfo, fp);
    
    cinfo.image_width = width;
    cinfo.image_height = height;
    cinfo.input_components = 1;
    cinfo.in_color_space = JCS_GRAYSCALE;
    //    cinfo.input_components = 3;
    //    cinfo.in_color_space = JCS_RGB;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, 75, TRUE);
    
    /* 圧縮開始 */
    jpeg_start_compress(&cinfo, TRUE);
    
    /* RGB値の設定 */
    JSAMPARRAY img = (JSAMPARRAY) malloc(sizeof(JSAMPROW) * height);
    for (int i = 0; i < height; i++) {
        img[i] = (JSAMPROW) malloc(sizeof(JSAMPLE) * width);
        for (int j = 0; j < width; j++) {
            img[i][j] = i;
        }
    }
    
    /* 書き込む */
    jpeg_write_scanlines(&cinfo, img, height);
    
    /* 圧縮終了 */
    jpeg_finish_compress(&cinfo);
    
    /* JPEGオブジェクトの破棄 */
    jpeg_destroy_compress(&cinfo);
    
    for (int i = 0; i < height; i++) {
        free(img[i]);
    }
    free(img);
    fclose(fp);
}
