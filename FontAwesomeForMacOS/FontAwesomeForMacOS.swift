//
//  FontAwesomeForMacOS.swift
//  FontAwesomeForMacOS
//
//  Created by Rémy Da Costa Faro on 08/07/2016.
//  Copyright © 2016 dacostafaro. All rights reserved.
//

import Cocoa
import CoreText

// MARK: - Public

/// A FontAwesome extension to UIFont.
public extension NSFont {
    
    /// Get a UIFont object of FontAwesome.
    ///
    /// - parameter fontSize: The preferred font size.
    /// - returns: A UIFont object of FontAwesome.
    public class func fontAwesomeOfSize(fontSize: CGFloat) -> NSFont {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        
        let name = "FontAwesome"
        if NSFont.fontNamesForFamilyName(name).isEmpty {
            dispatch_once(&Static.onceToken) {
                FontLoader.loadFont(name)
            }
        }
        
        return NSFont(name: name, size: fontSize)!
    }
    
    public class func fontNamesForFamilyName(fontName: String) -> [AnyObject] {
        let members = NSFontManager.sharedFontManager().availableMembersOfFontFamily(fontName)
        var result: [AnyObject] = []
        
        for array in members! {
            result.append(array[0])
        }
        
        return result
    }
}

/// A FontAwesome extension to String.
public extension String {
    
    /// Get a FontAwesome icon string with the given icon name.
    ///
    /// - parameter name: The preferred icon name.
    /// - returns: A string that will appear as icon with FontAwesome.
    public static func fontAwesomeIconWithName(name: FontAwesome) -> String {
        return name.rawValue.substringToIndex(name.rawValue.startIndex.advancedBy(1))
    }
    
    /// Get a FontAwesome icon string with the given CSS icon code. Icon code can be found here: http://fontawesome.io/icons/
    ///
    /// - parameter code: The preferred icon name.
    /// - returns: A string that will appear as icon with FontAwesome.
    public static func fontAwesomeIconWithCode(code: String) -> String? {
        guard let raw = FontAwesomeIcons[code], icon = FontAwesome(rawValue: raw) else {
            return nil
        }
        
        return self.fontAwesomeIconWithName(icon)
    }
}

/// A FontAwesome extension to UIImage.
public extension NSImage {
    
    /// Get a FontAwesome image with the given icon name, text color, size and an optional background color.
    ///
    /// - parameter name: The preferred icon name.
    /// - parameter textColor: The text color.
    /// - parameter size: The image size.
    /// - parameter backgroundColor: The background color (optional).
    /// - returns: A string that will appear as icon with FontAwesome
    public static func fontAwesomeIconWithName(name: FontAwesome, textColor: NSColor, size: CGSize, backgroundColor: NSColor = NSColor.clearColor()) -> NSImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let attributedString = NSAttributedString(string: String.fontAwesomeIconWithName(name), attributes: [NSFontAttributeName: NSFont.fontAwesomeOfSize(fontSize), NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor, NSParagraphStyleAttributeName: paragraph])
        
        let image = NSImage(size: size)
        image.lockFocus()
        attributedString.drawInRect(CGRectMake(0, 0, size.width, size.width))
        image.unlockFocus()
        return image
    }
}

// MARK: - Private

private class FontLoader {
    class func loadFont(name: String) {
        let bundle = NSBundle(forClass: FontLoader.self)
        var fontURL = NSURL()
        let identifier = bundle.bundleIdentifier
        
        if identifier?.hasPrefix("org.cocoapods") == true {
            // If this framework is added using CocoaPods, resources is placed under a subdirectory
            fontURL = bundle.URLForResource(name, withExtension: "otf", subdirectory: "FontAwesomeForMacOS.swift.bundle")!
        } else {
            fontURL = bundle.URLForResource(name, withExtension: "otf")!
        }
        
        let data = NSData(contentsOfURL: fontURL)!
        
        let provider = CGDataProviderCreateWithCFData(data)
        let font = CGFontCreateWithDataProvider(provider)!
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFStringRef = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSInternalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}
