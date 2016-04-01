import UIKit

//MARK:- Resize image
internal extension UIImage {
    
    internal func social_resize(size: CGSize) -> UIImage! {
        
        let selfImageRef = self.CGImage
        var selfBitmapInfo = CGImageGetBitmapInfo(selfImageRef)
        if (selfBitmapInfo.rawValue == CGImageAlphaInfo.None.rawValue) {
            selfBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipLast.rawValue)
        }
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(selfImageRef), 0, CGImageGetColorSpace(selfImageRef), selfBitmapInfo.rawValue)
        CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height))
        
        switch self.imageOrientation
        {
        case .Up, .UpMirrored:
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), selfImageRef)
            
        case .Left, .LeftMirrored:
            CGContextRotateCTM(context, CGFloat(M_PI_2))
            CGContextTranslateCTM(context, 0.0, -size.width)
            CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), selfImageRef)
            
        case .Right, .RightMirrored:
            CGContextRotateCTM(context, CGFloat(-M_PI_2))
            CGContextTranslateCTM(context, -size.height, 0.0)
            CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), selfImageRef)
            
        case .Down, .DownMirrored:
            CGContextRotateCTM(context, CGFloat(M_PI));
            CGContextTranslateCTM(context, -size.width, -size.height)
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), selfImageRef)
        }
        
        if let scaledImage = CGBitmapContextCreateImage(context) {
            return UIImage(CGImage: scaledImage)
        }
        
        return nil
    }
    
    internal func social_resizeProportionalRelativelySmallSide(size: CGSize) -> UIImage! {
        return self.social_resize(self.social_sizeProportionalRelativelySmallSide(size))
    }
    
    internal func social_resizeProportionalRelativelyBigSide(size: CGSize) -> UIImage! {
        return self.social_resize(self.social_sizeProportionalRelativelyBigSide(size))
    }
    
    internal func social_sizeProportionalRelativelySmallSide(size: CGSize) -> CGSize {
        var result = CGSizeZero
        if (self.size.width > self.size.height) {
            result = CGSizeMake((self.size.width/self.size.height) * size.height, size.height);
        } else {
            result = CGSizeMake(size.width, (self.size.height/self.size.width) * size.width);
        }
        return result
    }
    
    internal func social_sizeProportionalRelativelyBigSide(size: CGSize) -> CGSize {
        var result = CGSizeZero
        if (self.size.width < self.size.height) {
            result = CGSizeMake((self.size.width/self.size.height) * size.height, size.height);
        } else {
            result = CGSizeMake(size.width, (self.size.height/self.size.width) * size.width);
        }
        return result
    }
}

//MARK:- crop an image as square
internal extension UIImage {
    
    internal func social_cropSquare(size: CGSize) -> UIImage! {
        
        let resizedImage = self.social_resize(size)
        
        let originalWidth  = size.width
        let originalHeight = size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = floor((originalWidth  - edge) / 2.0)
        let posY = floor((originalHeight - edge) / 2.0)
        
        let cropSquare = CGRectMake(posX, posY, edge, edge)
        
        if let imageRef = CGImageCreateWithImageInRect(resizedImage.CGImage, cropSquare) {
            return UIImage(CGImage: imageRef)
        }
        
        return nil
    }
}

