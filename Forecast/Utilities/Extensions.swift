//
//  Extensions.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import UIKit
import MapKit

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self,preferredLocale: Locale(identifier: UserDefaultsManger.userDefaultHandler.getLanguage())) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}

extension UIView {
    func giveShadowAndRadius(scale: Bool = true, shadowRadius:Int, cornerRadius:Int) {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero
        layer.shadowRadius = CGFloat(integerLiteral: shadowRadius)
        layer.shouldRasterize = true
        layer.cornerRadius = CGFloat(integerLiteral: cornerRadius)
        layer.masksToBounds = false
    }
}

extension UILabel {
    func adjustHeaderFontSizeBasedOnLanguage(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            self.font = self.font.withSize(50)
        }
        else{
            self.font = self.font.withSize(35)
        }
    }
}

extension String {
    private static let formatter = NumberFormatter()

    func clippingCharacters(in characterSet: CharacterSet) -> String {
        components(separatedBy: characterSet).joined()
    }

    func convertedDigitsToLocale(_ locale: Locale = .current) -> String {
        let digits = Set(clippingCharacters(in: CharacterSet.decimalDigits.inverted))
        guard !digits.isEmpty else { return self }

        Self.formatter.locale = locale

        let maps: [(original: String, converted: String)] = digits.map {
            let original = String($0)
            let digit = Self.formatter.number(from: original)!
            let localized = Self.formatter.string(from: digit)!
            return (original, localized)
        }

        return maps.reduce(self) { converted, map in
            converted.replacingOccurrences(of: map.original, with: map.converted)
        }
    }
}


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}
extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime])
}
extension Date {
    var iso8601: String { return Formatter.iso8601.string(from: self) }
}
