//
//  main.m
//  6--CATiledLayer--demo1
//
//  Created by cxs on 2018/6/24.
//  Copyright © 2018年 cxs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AppKit/AppKit.h>


/**
 简单的Mac OS命令行程序：将图片裁剪成小图片并存储到不同的文件中

 @param argc 数组元素个数
 @param argv 数组指针
 @return 返回
 */
int main(int argc, const char * argv[])
{
    @autoreleasepool{
        //handle incorrect arguments 参数个数需要等于2, tile Cutter:瓷砖切割机
        if (argc < 2) {
            NSLog(@"TileCutter arguments: inputfile"); //瓷砖切割机参数： 输入文件
            return 0;
        }
        
        //input file 输入文件
        NSString *inputFile = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        
        //tile size 每块的大小
        CGFloat tileSize = 256;
        
        //output path 输出文件
        NSString *outputPath = [inputFile stringByDeletingPathExtension];
        
        //load image 加载图片
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:inputFile];
        
        //计算图片点的大小
        NSSize size = [image size];
        //NSLog(@"origin image size: %@", NSStringFromSize(size));
        NSArray *representations = [image representations];
        if ([representations count]){
            //计算图片像素大小
            NSBitmapImageRep *representation = representations[0];
            size.width = [representation pixelsWide];
            size.height = [representation pixelsHigh];
           // NSLog(@"image representation size: %@", NSStringFromSize(size));
        }
        NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
        CGImageRef imageRef = [image CGImageForProposedRect:&rect context:NULL hints:nil];
        
        //calculate rows and columns
        NSInteger rows = ceil(size.height / tileSize);
        NSInteger cols = ceil(size.width / tileSize);
        
        //generate tiles
        for (int y = 0; y < rows; ++y) {
            for (int x = 0; x < cols; ++x) {
                //extract tile image 提取贴片图片
                CGRect tileRect = CGRectMake(x*tileSize, y*tileSize, tileSize, tileSize);
                CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, tileRect);
                
                //convert to jpeg date 转换为数据
                NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:tileImage];
                
                NSData *data = [imageRep representationUsingType: NSJPEGFileType properties:[NSDictionary new]];
                CGImageRelease(tileImage);
                
                //save file  保存文件
                NSString *path = [outputPath stringByAppendingFormat: @"_%02i_%02i.jpg", x, y];
                [data writeToFile:path atomically:NO];
            }
        }
    }
    return 0;
}
