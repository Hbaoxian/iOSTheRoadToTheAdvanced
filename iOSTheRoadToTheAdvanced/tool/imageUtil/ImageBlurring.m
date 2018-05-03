//
//  ImageBlurring.m
//  iOSTheRoadToTheAdvanced
//
//  Created by 黄保贤 on 2018/5/3.
//  Copyright © 2018年 黄保贤. All rights reserved.
//

#import "ImageBlurring.h"
#import <Accelerate/Accelerate.h>
#import "NYXImagesHelper.h"

static int16_t __s_gaussianblur_kernel_5x5[25] = {
    1, 4, 6, 4, 1,
    4, 16, 24, 16, 4,
    6, 24, 36, 24, 6,
    4, 16, 24, 16, 4,
    1, 4, 6, 4, 1
};



@implementation ImageBlurring

+ (UIImage*)gaussianBlurWithBias:(NSInteger)bias valueImg:(UIImage *)valueImage
{
    /// Create an ARGB bitmap context
    const size_t width = (size_t)valueImage.size.width;
    const size_t height = (size_t)valueImage.size.height;
    const size_t bytesPerRow = width * kNyxNumberOfComponentsPerARBGPixel;
    CGContextRef bmContext = NYXCreateARGBBitmapContext(width, height, bytesPerRow, NYXImageHasAlpha(valueImage.CGImage));
    if (!bmContext)
        return nil;
    
    /// Draw the image in the bitmap context
    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = height}, valueImage.CGImage);
    
    /// Grab the image raw data
    UInt8* data = (UInt8*)CGBitmapContextGetData(bmContext);
    if (!data)
    {
        CGContextRelease(bmContext);
        return nil;
    }
    
    const size_t n = sizeof(UInt8) * width * height * 4;
    void* outt = malloc(n);
    vImage_Buffer src = {data, height, width, bytesPerRow};
    vImage_Buffer dest = {outt, height, width, bytesPerRow};
    vImageConvolveWithBias_ARGB8888(&src, &dest, NULL, 0, 0, __s_gaussianblur_kernel_5x5, 5, 5, 256/*divisor*/, (int32_t)bias, NULL, kvImageCopyInPlace);
    memcpy(data, outt, n);
    free(outt);
    
    CGImageRef blurredImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* blurred = [UIImage imageWithCGImage:blurredImageRef];
    
    /// Cleanup
    CGImageRelease(blurredImageRef);
    CGContextRelease(bmContext);
    
    return blurred;
}



@end
