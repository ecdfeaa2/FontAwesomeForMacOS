//
//  FontAwesomeForMacOS.swift
//  FontAwesomeForMacOS
//
//  Created by Remy Da Costa Faro on 08/07/2016.
//  Copyright © 2017 Remy Da Costa Faro. All rights reserved.
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

    public class func fontAwesome(ofSize fontSize: CGFloat) -> NSFont {
        let name = "FontAwesome"
        if NSFont.fontNamesForFamilyName(name).isEmpty {
                FontLoader.loadFont(name)
        }
        
        return NSFont(name: name, size: fontSize)!
    }
    
    public class func fontNamesForFamilyName(_ fontName: String) -> [AnyObject] {
        let members = NSFontManager.shared().availableMembers(ofFontFamily: fontName)
        var result: [AnyObject] = []
        
        for array in members! {
            result.append(array[0] as AnyObject)
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
    public static func fontAwesomeIconWithName(_ name: FontAwesome) -> String {
        return name.rawValue.substring(to: name.rawValue.characters.index(name.rawValue.startIndex, offsetBy: 1))
    }
    
    /// Get a FontAwesome icon string with the given CSS icon code. Icon code can be found here: http://fontawesome.io/icons/
    ///
    /// - parameter code: The preferred icon name.
    /// - returns: A string that will appear as icon with FontAwesome.
    public static func fontAwesomeIconWithCode(_ code: String) -> String? {
        guard let raw = FontAwesomeIcons[code], let icon = FontAwesome(rawValue: raw) else {
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
    public static func fontAwesomeIconWithName(_ name: FontAwesome, textColor: NSColor, size: CGSize, backgroundColor: NSColor = NSColor.clear) -> NSImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let attributedString = NSAttributedString(string: String.fontAwesomeIconWithName(name), attributes: [NSFontAttributeName: NSFont.fontAwesome(ofSize: fontSize), NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor, NSParagraphStyleAttributeName: paragraph])
        
        let image = NSImage(size: size)
        image.lockFocus()
        attributedString.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.width))
        image.unlockFocus()
        return image
    }
}

// MARK: - Private

private class FontLoader {
    class func loadFont(_ name: String) {
        let bundle = Bundle(for: FontLoader.self)
        let identifier = bundle.bundleIdentifier
        
        var fontURL: URL
        if identifier?.hasPrefix("org.cocoapods") == true {
            // If this framework is added using CocoaPods, resources is placed under a subdirectory
            fontURL = bundle.url(forResource: name, withExtension: "otf", subdirectory: "FontAwesomeForMacOS.swift.bundle")!
        } else {
            fontURL = bundle.url(forResource: name, withExtension: "otf")!
        }
        
        let data = try! Data(contentsOf: fontURL)
        
        let provider = CGDataProvider(data: data as CFData)
        let font = CGFont(provider!)
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}
