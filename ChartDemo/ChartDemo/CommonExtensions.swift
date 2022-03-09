//
//  CommonExtensions.swift
//
//  Created by HanQi on 2020/10/26.
//

import Foundation
import UIKit

// MARK - UIView
extension UIView {
    
    /// 阴影偏移
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    /// 阴影半径
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    /// 阴影透明度
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    /// 阴影颜色
    @IBInspectable var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    /// 圆角
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var cornerRadiusWithOutMask: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    
    
    /// 描边的粗细
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 描边的颜色
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    /// 倒计时
    /// - Parameters:
    ///   - repeatTimes: 重复次数
    ///   - spacing: 重复时间间隔
    ///   - timerInit: 初始化
    ///   - timerProgress: 倒计时
    ///   - timerEnd: 结束
    class func countdown(_ repeatTimes: Int, spacing: TimeInterval, timerInit: ((_ countTime: Int) -> Void)? = nil, timerProgress: ((_ lastTime: Int) -> Void)? = nil, timerEnd: (() -> Void)? = nil) {

        timerInit == nil ? nil : timerInit!(repeatTimes * Int(spacing))
        let endTime = CACurrentMediaTime() + (Double(repeatTimes) * spacing)

        let timer = DispatchSource.makeTimerSource(flags: [], queue: .global())
        timer.schedule(deadline: .now() + spacing, repeating: spacing, leeway: .seconds(1))
        timer.setEventHandler {
            let timeSpacing = lround(endTime - CACurrentMediaTime())
            if timeSpacing > 0 {
                DispatchQueue.main.async {
                    timerProgress == nil ? nil : timerProgress!(timeSpacing)
                }
            } else {
                timer.cancel()
                DispatchQueue.main.async {
                    timerEnd == nil ? nil : timerEnd!()
                }
            }
        }
        timer.resume()
    }
    
    /// 设置部分圆角（绝对布局）
    ///
    /// - Parameters:
    ///   - corners: 需要设置的角
    ///   - radii: 圆角大小
    public func addRoundedCorners(_ corners: UIRectCorner, withRadii radii: CGSize) -> Void {
        let path = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
        let shap = CAShapeLayer.init()
        shap.path = path.cgPath
        self.layer.mask = shap
    }
    
    /// 设置部分圆角（相对布局）
    ///
    /// - Parameters:
    ///   - corners: 需要设置的角
    ///   - radii: 圆角大小
    public func addRoundedCorners(_ corners: UIRectCorner, withRadii radii: CGSize, viewRect rect: CGRect) -> Void {
        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
        let shap = CAShapeLayer.init()
        shap.path = path.cgPath
        self.layer.mask = shap
    }
    
    //两个color设置横向渐变色
    func xp_setHorizontalGradientByColor(left color: UIColor,right color1: UIColor) {
        self.xp_setGradientByColor(color: color, color1: color1, start: CGPoint(x: 0, y: 0.5), end: CGPoint(x: 1, y: 0.5));
    }
    ///color添加渐变色
    func xp_setVerticalGradientByColor(top color: UIColor,bottom color1: UIColor) {
        self.xp_setGradientByColor(color: color, color1: color1, start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1));
    }
    ///添加渐变色
    func xp_setGradientByColor(color: UIColor, color1: UIColor, start: CGPoint, end: CGPoint) {
        let gradientColors          = [color.cgColor, color1.cgColor];
        
        let gradientLayer           = CAGradientLayer();
        gradientLayer.colors        = gradientColors;
        gradientLayer.startPoint    = start;
        gradientLayer.endPoint      = end;
        gradientLayer.frame         = self.bounds;
        self.layer.insertSublayer(gradientLayer, at: 0);
    }
    ///设置边框
    func xp_setCornerRadius(borderColor: UIColor = .red, borderWidth: CGFloat = 1.0){
        self.layer.borderColor = borderColor.cgColor;
        self.layer.borderWidth = borderWidth;
    }
    
    /// 加载Xib View
    /// - Parameter frame: CGRect
    /// - Returns: View
    class func loadFromNib(frame: CGRect = .zero) -> Self {
        let named = String(describing: Self.self)
        let bundle = Bundle(for: Self.self)
        guard let view = UINib(nibName: named, bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as? Self else {
            fatalError("not find\(named)")
        }
        if frame != .zero {
            view.frame = frame
        }
        return view
    }
}

// MARK: - UILabel
extension UILabel {
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            text = NSLocalizedString(newValue, comment: " ")
        }
        get { return text }
    }
    
    func addUnderLine(_ text: String) {
        let range = NSRange(location: 0, length: text.count)
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        attr.addAttribute(.underlineColor, value: self.textColor ?? .white, range: range)
        attr.addAttribute(.foregroundColor, value: self.textColor ?? .white, range: range)
        
        self.attributedText = attr
    }
}

// MARK: - UIButton
extension UIButton {
    
    @IBInspectable var localizedKey: String? {
        set {
            guard let newValue = newValue else { return }
            setTitle(NSLocalizedString(newValue, comment: " "), for: .normal)
        }
        get { return titleLabel?.text }
        
    }
    
    /// 添加下划线
    func withUnderLine(_ text: String? = nil) {
        if let text = text ?? titleLabel?.text, let font = titleLabel?.font {
            let attributedString = NSMutableAttributedString.init(string: text, attributes: [
                NSAttributedString.Key.foregroundColor : currentTitleColor,
                NSAttributedString.Key.font : font,
                NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
            ])
            titleLabel?.attributedText = attributedString
        } else if let text = titleLabel?.attributedText {
            let attributedString = NSMutableAttributedString.init(attributedString: text)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length)) 
            titleLabel?.attributedText = attributedString
        }
    }
    
}

// MARK: - UIImage
extension UIImage {
    /// 颜色生成图片
    /// - Parameters:
    ///   - color: color
    ///   - size: size
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: aCgImage)
    }
    
    /// 颜色生成图片
    /// - Parameters:
    ///   - color: color
    ///   - size: size
    /// - Returns: image
    class func image(with color: UIColor?, size: CGSize) -> UIImage {
        guard let color = color, size != .zero else {
            return .init()
        }
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? .init()
    }
    
    /// 根据layer获取图片
    /// - Parameter layer: layer
    /// - Returns: image
    class func image(with layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image ?? .init()
        }
        return .init()
    }
    
    /// 由颜色生成图片
    /// - Parameters:
    ///   - color: color
    ///   - rect: 区域
    ///   - inSize: in
    ///   - fillColor: 填充色
    /// - Returns: 图片
    class func image(with color: UIColor?, rect: CGRect, in inSize: CGSize, fill fillColor: UIColor?) -> UIImage {
        let image = UIImage.image(with: color, size: .init(width: rect.width, height: rect.height))
        let inImage = UIImage.image(with: fillColor, size: inSize)
        return inImage.merge(image: image, at: rect)
    }
    
    /// 合并图片
    /// - Parameters:
    ///   - image: image
    ///   - rect: rect
    /// - Returns: 图片
    func merge(image: UIImage, at rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: .init(x: 0, y: 0, width: size.width, height: size.height))
        image.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? .init()
    }
    
    /// 自由拉伸一张图片
    /// - Parameter left: 左边开始位置比例  值范围0-1
    /// - Parameter top: 上边开始位置比例  值范围0-1
    public func resizeImage(left: CGFloat, top: CGFloat) -> UIImage {
        return self.stretchableImage(withLeftCapWidth: Int(CGFloat(self.size.width * left)), topCapHeight: Int(CGFloat(self.size.height * top)))
    }
    
    /// 自由拉伸一张图片
    /// - Parameter left: 左边开始位置像素
    /// - Parameter top: 上边开始位置像素
    public func resizeImage(leftPX: Int, topPX: Int) -> UIImage {
        return self.stretchableImage(withLeftCapWidth: leftPX, topCapHeight: topPX)
    }
    
    /// 压缩图片，返回data
    /// - Parameter max: 最大的值 1K = 1024, 1M = 1024*1024
    /// - Returns: 压缩后的data
    public func xp_compression(_ max: Int, step: CGFloat = 0.01) -> Data? {
        guard var data = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        var quality: CGFloat = 1
        while data.count > max {
            quality -= step
            data = self.jpegData(compressionQuality: quality)!
        }
        return data;
    }
}

extension CAGradientLayer {
    
    /// 生成渐变layer
    /// - Parameters:
    ///   - withRect: rect
    ///   - colors: color
    ///   - locations: location
    ///   - isVertical: direction
    /// - Returns: layer
    static func layer(_ withRect: CGRect, colors: [UIColor], locations: [Float], isVertical: Bool = true) -> CAGradientLayer {
        let gl = CAGradientLayer.init()
        gl.frame = withRect
        if isVertical {
            gl.startPoint = .init(x: 0.5, y: 0)
            gl.endPoint = .init(x: 0.5, y: 1)
        } else {
            gl.startPoint = .init(x: 0, y: 0.5)
            gl.endPoint = .init(x: 1, y: 0.5)
        }
        gl.colors = colors.map( { $0.cgColor } )
        gl.locations = locations.map( { NSNumber.init(value: $0) } )
        return gl
    }
    
}

// MARK: - Array
extension Array {
    public subscript(safe index: Int) -> Element? {
        return (0 ..< count).contains(index) ? self[index] : nil
    }
    
    public func random(_ randomCount: Int) -> [Element] {
        var temp: [Element] = self
        var result: [Element] = []
        if isEmpty {
            return result
        }
        let minCount = Swift.min(count, randomCount)
        for _ in 0 ..< minCount {
            result.append(temp.remove(at: Int.random(in: 0 ..< temp.count)))
        }
        return result
    }
}

// MARK: - String
extension String {
    
    var isEmail: Bool {
        let pattern = "^\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]*.)+[A-Za-z]{2,14}$"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    
    /// range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    /// 字符串的匹配范围 方法一
    ///
    /// - Parameters:
    /// - matchStr: 要匹配的字符串
    /// - Returns: 返回所有字符串范围
    @discardableResult
    func exMatchStrRange(_ matchStr: String) -> [NSRange] {
        var allLocation = [Int]() //所有起点
        let matchStrLength = (matchStr as NSString).length  //currStr.characters.count 不能正确统计表情

        let arrayStr = self.components(separatedBy: matchStr)//self.componentsSeparatedByString(matchStr)
        var currLoc = 0
        arrayStr.forEach { currStr in
            currLoc += (currStr as NSString).length
            allLocation.append(currLoc)
            currLoc += matchStrLength
        }
        allLocation.removeLast()
        return allLocation.map { NSRange(location: $0, length: matchStrLength) } //可把这段放在循环体里面，同步处理，减少再次遍历的耗时
    }
    
    /// 获取适合宽度的字号
    /// - Parameters:
    ///   - weight: weight
    ///   - startSize: 最大字号
    ///   - maxWidth: 宽度
    /// - Returns: 字号
    func adaptSize(for weight: UIFont.Weight, startSize: CGFloat, maxWidth: CGFloat) -> CGFloat {
        var size = startSize
        for _ in 0 ..< (Int(startSize) - 6) {
            size -= 1
            if self.width(with: UIFont.systemFont(ofSize: size, weight: weight)) <= maxWidth {
                break
            }
        }
        return size
    }
    
    /// 不换行 获取文本宽度
    /// - Parameter font: font
    /// - Returns: width
    public func width(with font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font : font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect: CGRect = NSString.init(string: self).boundingRect(with: .init(width: CGFloat.init(MAXFLOAT), height: CGFloat.init(MAXFLOAT)), options: option, attributes: attributes, context: nil)
        return ceil(rect.width)
    }
    
    /// 创建随机字符串
    /// - Parameter length: 长度
    /// - Returns: 字符串
    public static func random(with length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            ranStr.append(characters[index])
        }
        return ranStr
    }
    
    public static func randomNumberString(with length: Int) -> String {
        let characters = "0123456789"
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            if ranStr.isEmpty {
                if characters[index] != "0" {
                    ranStr.append(characters[index])
                }
            } else {
                ranStr.append(characters[index])
            } 
        }
        if ranStr.isEmpty {
            return randomNumberString(with: length)
        }
        return ranStr
    }
    
    public subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    /// 判断是不是Emoji
    ///
    /// - Returns: true false
    func containsEmoji()->Bool{
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,
                 0x1F300...0x1F5FF,
                 0x1F680...0x1F6FF,
                 0x2600...0x26FF,
                 0x2700...0x278A,
                 0x2793...0x27BF,
                 0xFE00...0xFE0F,
                 //🈁
                 0x1F201,
                 //旗帜
                 0x1F1E6...0x1F1FF:
                return true
            default:
                continue
            }
        }
        
        return false
    }
    
    /// 判断是不是Emoji
    ///
    /// - Returns: true false
    func hasEmoji()->Bool {
        
        let pattern = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    
    
}

public extension CAGradientLayer {
    
    enum GradientDirection {
        case horizontal
        case vertical
    }
    
    convenience init(frame: CGRect,
                     colors: [UIColor],
                     locations: [CGFloat]? = nil,
                     startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
                     endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) {
        self.init()
        self.frame = frame
        self.colors = colors.map(\.cgColor)
        self.locations = locations?.map { NSNumber(value: Double($0)) }
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    convenience init(frame: CGRect,
                     colors: [UIColor],
                     direction: GradientDirection = .horizontal) {
        
        var start = CGPoint(x: 0, y: 0.5)
        var end = CGPoint(x: 1, y: 0.5)
        if direction == .vertical {
            start = CGPoint.init(x: 0.5, y: 0)
            end = CGPoint.init(x: 0.5, y: 1)
        }
        self.init(frame: frame,
                  colors: colors,
                  startPoint: start,
                  endPoint: end)
    }
    
}

// MARK: - UIDevice
extension UIDevice {
    
    public static func systemLanguage() -> (lang: String, langContry: String) {
        let defs = UserDefaults.standard
        let languages = defs.object(forKey: "AppleLanguages")//获取系统支持的所有语言集合
        let preferredLanguage = (languages! as! [String]).first
        if preferredLanguage == nil{
            return ("en","en_US")
        }
        
        if let code = Locale.current.regionCode {
            let codeStr = String(format: "-%@", code)
            let c = preferredLanguage!
            let languageCode = c.replacingOccurrences(of: codeStr, with: "")
            if languageCode == "zh-Hans" {
                return ("en", "en_US")
            }
            return (languageCode, c)
        }
        return ("en", "en_US")
    }
    
    ///系统版本号
    public static func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    ///app版本号
    public static func getAppVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String;
    }
    
    ///app build号
    public static func getAppBuildVersion() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String;
    }
    
    ///设备信息
    public static func getDeviceName() -> String {
        var systemInfo = utsname();
        uname(&systemInfo);
        let machineMirror = Mirror(reflecting: systemInfo.machine);
        let id = machineMirror.children.reduce("") { (id, args) in
            guard let value = args.value as? Int8,
                  value != 0 else {
                return id;
            }
            return id + String(UnicodeScalar(UInt8(value)));
        }
        
        switch id {
        case "iPod5,1":
            return "iPod Touch 5";
        case "iPod7,1":
            return "iPod Touch 6";
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            return "iPhone 4";
        case "iPhone4,1":
            return "iPhone 4s";
        case "iPhone5,1","iPhone5,2":
            return "iPhone 5";
        case "iPhone5,3", "iPhone5,4":
            return "iPhone 5c";
        case "iPhone6,1", "iPhone6,2":
            return "iPhone 5s";
        case "iPhone7,2":
            return "iPhone 6";
        case "iPhone7,1":
            return "iPhone6 Plus";
        case "iPhone8,1":
            return "iPhone 6s";
        case "iPhone8,2":
            return "iPhone6s Plus";
        case "iPhone8,4":
            return "iPhoneSE"
        case "iPhone9,1", "iPhone9,3":
            return "iPhone 7";
        case "iPhone9,2", "iPhone9,4":
            return "iPhone7 Plus";
        case "iPhone10,1", "iPhone10,4":
            return "iPhone 8";
        case "iPhone10,5", "iPhone10,2":
            return "iPhone8 Plus";
        case "iPhone10,3", "iPhone10,6":
            return "iPhone X";
        case "iPhone11,2":
            return"iPhone XS";
        case "iPhone11,6":
            return"iPhone XS MAX";
        case "iPhone11,8":
            return "iPhone XR";
            
        case "iPhone12,1":
            return "iPhone 11";
        case "iPhone12,3":
            return "iPhone 11 Pro";
        case "iPhone12,5":
            return "iPhone 11 Pro Max";
        case "iPhone12,8":
            return "iPhone SE (2nd generation)";
            
        case "iPhone13,1":
            return "iPhone 12 mini";
        case "iPhone13,2":
            return "iPhone 12";
        case "iPhone13,3":
            return "iPhone 12 Pro";
        case "iPhone13,4":
            return "iPhone 12 Pro Max";
            
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            return "iPad 2";
        case "iPad3,1", "iPad3,2", "iPad3,3":
            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":
            return "iPad 4";
        case "iPad4,1", "iPad4,2", "iPad4,3":
            return "iPad Air";
        case"iPad5,3","iPad5,4":
            return"iPad Air 2";
        case "iPad2,5", "iPad2,6", "iPad2,7":
            return "iPad Mini";
        case "iPad4,4", "iPad4,5", "iPad4,6":
            return "iPad Mini 2";
        case "iPad4,7", "iPad4,8", "iPad4,9":
            return "iPad Mini 3";
        case"iPad5,1","iPad5,2":
            return"iPad Mini 4";
        case"iPad6,7","iPad6,8":
            return"iPad Pro";
        case"AppleTV5,3":
            return"Apple TV";
        case"i386","x86_64":
            return"Simulator";
        default:
            return id;
        }
    }
}

// MARK: - UIColor
extension UIColor {
    
    /// 解析color,返回（r,g,b,a）
    /// - Returns: 返回（r,g,b,a）
    public func xp_getRBG() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0;
        
        self.getRed(&r,
                    green: &g,
                    blue: &b,
                    alpha: &a);
        return (r, g, b, a);
    }
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines);
        hex = hex.hasPrefix("#") ? String(hex.suffix(hex.count-1)) : hex
        let scanner = Scanner(string: hex);
        var color: UInt64 = 0;
        scanner.scanHexInt64(&color);
        //
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask;
        let g = Int(color >> 8) & mask;
        let b = Int(color) & mask;
        //
        let red     = CGFloat(r) / 255.0;
        let green   = CGFloat(g) / 255.0;
        let blue    = CGFloat(b) / 255.0;
        
        self.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
}

// MARK: - UITableView
public extension UITableView {
    // MARK: - Cell register and reuse
    /**
     Register cell nib
     
     - parameter aClass: class
     */
    func registerCellNib<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forCellReuseIdentifier: name)
    }
    
    /**
     Register cell class
     
     - parameter aClass: class
     */
    func registerCellClass<T: UITableViewCell>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        self.register(aClass, forCellReuseIdentifier: name)
    }
    
    /**
     Reusable Cell
     
     - parameter aClass:    class
     
     - returns: cell
     */
    func dequeueReusableCell<T: UITableViewCell>(_ aClass: T.Type, _ indexPath: IndexPath) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableCell(withIdentifier: name,for: indexPath) as? T else {
            fatalError("\(name) is not registed")
        }
        return cell
    }
    
    // MARK: - HeaderFooter register and reuse
    /**
     Register cell nib
     
     - parameter aClass: class
     */
    func registerHeaderFooterNib<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: name)
    }
    
    /**
     Register cell class
     
     - parameter aClass: class
     */
    func registerHeaderFooterClass<T: UIView>(_ aClass: T.Type) {
        let name = String(describing: aClass)
        self.register(aClass, forHeaderFooterViewReuseIdentifier: name)
    }
    
    /**
     Reusable Cell
     
     - parameter aClass:    class
     
     - returns: cell
     */
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ aClass: T.Type) -> T! {
        let name = String(describing: aClass)
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: name) as? T else {
            fatalError("\(name) is not registed")
        }
        return cell
    }

}

extension Date {
    
    ///单位：秒
    ///计算两个秒级时间戳相隔多少天
    public static func xp_trampDaysApart(time1: Int, time2: Int) -> Int {
        
        let server = Date(timeIntervalSince1970: TimeInterval(time1))
        let expire = Date(timeIntervalSince1970: TimeInterval(time2))
         
        let components = Calendar.current.dateComponents([.day], from: server, to: expire)
        
        return components.day ?? 0
    }
    /// tramp:单位秒
    /// 时间戳转字符串
    public static func xp_trampToDataFormat(_ tramp: Int, dateFormat: String = "yyyy/MM/dd") -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(tramp))
        
        let format = DateFormatter()
        format.dateFormat = dateFormat
        
        return format.string(from: date)
    }
    
    public func trampToString(dateFormat: String = "yyyy-MM-dd") -> String {
        let format = DateFormatter()
        format.dateFormat = dateFormat
        return format.string(from: self)
    }
    
    /// 年
    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// 月
    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// 日
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// 时
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// 分
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// 秒
    public var second: Int {
        return Calendar.current.component(.second, from: self)
    }
}

extension UITextField {
    
    private struct AssociatedObjectByHQ {
        static var clear = "AssociatedObjectByHQ.isSecureBeginClear"
        static var setSecureTextEntryChanged = false
    }
    
    public var isSecureBeginClear: Bool {
        get {
            objc_getAssociatedObject(self, &AssociatedObjectByHQ.clear) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectByHQ.clear, newValue, .OBJC_ASSOCIATION_COPY)
            if !newValue {
                if !AssociatedObjectByHQ.setSecureTextEntryChanged {
                    AssociatedObjectByHQ.setSecureTextEntryChanged = true
                    guard let m1 = class_getInstanceMethod(self.classForCoder, Selector(("setSecureTextEntry:"))) else {
                        return
                    }
                    guard let m2 = class_getInstanceMethod(self.classForCoder, #selector(hq_setSecureTextEntry(_:))) else {
                        return
                    }
                    method_exchangeImplementations(m1, m2)
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(textDidBeginEditingNotificationFunc(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self)
                endEditing(true)
            }
        }
    }
     
    @objc private func hq_setSecureTextEntry(_ new: Bool) {
        hq_setSecureTextEntry(new)
        if !isSecureBeginClear {
            if let text = self.text, isFirstResponder {
                self.text = ""
                self.insertText(text)
                self.insertText("")
            }
        }
    }
    
    @objc private func textDidBeginEditingNotificationFunc(_ notification: NSNotification) {
        if let textField = notification.object as? UITextField, textField == self, textField.isSecureTextEntry {
            if let text = textField.text {
                textField.text = ""
                textField.insertText(text)
                textField.insertText("")
            }
        }
    }
    
}

// MARK: - DispatchQueue
extension DispatchQueue {
    private static var _onceToken = [String]()
    
    class func once(token: String = "\(#file):\(#function):\(#line)", block: ()->Void) {
        objc_sync_enter(self)
        
        defer {
            objc_sync_exit(self)
        }
        
        if _onceToken.contains(token) {
            return
        }
        
        _onceToken.append(token)
        block()
    }
}
