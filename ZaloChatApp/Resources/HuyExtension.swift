//
//  HuyExtension.swift
//  ZaloChatApp
//
//  Created by huy on 12/10/2022.
//

import Foundation
import JGProgressHUD

extension UIView {
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }

    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }

    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }

    var bottom: CGFloat {
        return frame.size.height+frame.origin.y
    }

    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }

    var right: CGFloat {
        return frame.size.width+frame.origin.x
    }
}

extension UIImage {
    func isEqualToImage(_ image: UIImage) -> Bool {
        return self.pngData() == image.pngData()
    }
}

extension Notification.Name {
    static let didSignOut = Notification.Name("didSignOut")
}

extension String {
    /*
     NSC - Non Special Characters
     UCD - Unicode Characters Detected
     RWR - Redundant Whitespaces Removed
     */

    func NSC_UCD_RWR_map() -> (String, String) {
        let components = self.components(separatedBy: .whitespaces)
        var result1 = ""
        var result2 = ""

        for component in components {
            guard component.count > 0 else {
                continue
            }

            // partialResult là một tuple gồm 2 thành phần kiểu String có tên accentedComponent và nonAccentedComponents
            let (accentedStringResult, nonAccentedStringResult) = component.reduce((accentedComponent: "", nonAccentedComponent: "")) { partialResult, char in

                var nextAccentedComponent = ""
                var nextNonAccentedComponent = ""
                if char.isLetter {
                    // BEGIN - Xử lý thành phần thứ hai của kết quả đầu ra
                    // Kiểm tra nếu chữ cái có dấu
                    switch char {
                    case "á", "à", "ả", "ã", "ạ", "ă", "ắ", "ằ", "ẳ", "ẵ", "ặ", "â", "ấ", "ầ", "ẩ", "ẫ", "ậ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"a"
                    case "Á", "À", "Ả", "Ã", "Ạ", "Ă", "Ắ", "Ằ", "Ẳ", "Ẵ", "Ặ", "Â", "Ấ", "Ầ", "Ẩ", "Ẫ", "Ậ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"A"
                    case "é", "è", "ẻ", "ẽ", "ẹ", "ê", "ế", "ề", "ể", "ễ", "ệ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"e"
                    case "É", "È", "Ẻ", "Ẽ", "Ẹ", "Ê", "Ế", "Ề", "Ể", "Ễ", "Ệ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"E"
                    case "ó", "ò", "ỏ", "õ", "ọ", "ô", "ố", "ồ", "ổ", "ỗ", "ộ", "ơ", "ớ", "ờ", "ở", "ỡ", "ợ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"o"
                    case "Ó", "Ò", "Ỏ", "Õ", "Ọ", "Ô", "Ố", "Ồ", "Ổ", "Ỗ", "Ộ", "Ơ", "Ớ", "Ờ", "Ở", "Ỡ", "Ợ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"O"
                    case "í", "ì", "ỉ", "ĩ", "ị":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"i"
                    case "Í", "Ì", "Ỉ", "Ĩ", "Ị":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"I"
                    case "ú", "ù", "ủ", "ũ", "ụ", "ư", "ứ", "ừ", "ử", "ữ", "ự":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"u"
                    case "Ú", "Ù", "Ủ", "Ũ", "Ụ", "Ư", "Ứ", "Ừ", "Ử", "Ữ", "Ự":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"U"
                    case "ý", "ỳ", "ỷ", "ỹ", "ỵ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"y"
                    case "Ý", "Ỳ", "Ỷ", "Ỹ", "Ỵ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"Y"
                    case "đ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"d"
                    case "Đ":
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+"D"
                    default:
                        // Các trường hợp còn lại là chữ cái không có dấu
                        // Kiểm tra nếu có trường hợp ngoài mong muốn
                        nextNonAccentedComponent = partialResult.nonAccentedComponent+String(char)
                    }
                    // END - Xử lý thành phần thứ hai của kết quả đầu ra

                    // BEGIN - Xử lý thành phần thứ nhất của kết quả đầu ra
                    nextAccentedComponent = partialResult.accentedComponent+String(char)
                    // END - Xử lý thành phần thứ nhất của kết quả đầu ra
                }
                else if "0" ... "9" ~= char {
                    nextAccentedComponent = partialResult.accentedComponent+String(char)
                    nextNonAccentedComponent = partialResult.nonAccentedComponent+String(char)
                }
                else {
                    return partialResult
                }

                return (nextAccentedComponent, nextNonAccentedComponent)
            }

            result1 += !accentedStringResult.isEmpty ? "\(accentedStringResult) " : ""
            result2 += !nonAccentedStringResult.isEmpty ? "\(nonAccentedStringResult) " : ""
        }
        // popLast() do dư một kí tự khoảng trắng ở cuối chuỗi kết quả.
        _ = result1.popLast()
        _ = result2.popLast()
        return (result1, result2)
        /*
         Kết quả kiểm thử (Lưu ý chuỗi không xuống dòng!):
         "Dương Xuân Huy" -> ("Dương Xuân Huy", "Duong Xuan Huy")
         "Duong Xuan Huy" -> ("Duong Xuan huy), "Duong Xuan Huy")
         "Dương1 Xuân2 Huy3 1609" -> ("Dương1 Xuân2 Huy3 1609", "Duong1 Xuan2 Huy3 1609")
         "Duong1 Xuan2 Huy3 1609" -> ("Duong1 Xuan2 Huy3 1609", "Duong1 Xuan2 Huy3 1609")
         #"~!@#$%^&*()_+{}|:"<>?`-=[]\;',./       ~!@#$%^&*()_+',./Dương1{}|:"<>?`-=[]\;            ~!@#$%^&*()_+{}|:"<>?`-=[]\;',./    ~!@#$%^&*()_+',./Xuân2{}|:"<>?`-=[]\;    ~!@#$%^&*()_+{}|:"<>?`-=[]\;',./     ~!@#$%^&*()_+',./Huy3{}|:"<>?`-=[]\;           ~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;16092002~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;           ~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;"# -> ("Dương1 Xuân2 Huy3 Xuân116092002Xuân1 Xuân1", "Duong1 Xuan2 Huy3 Xuan116092002Xuan1 Xuan1")
         */
    }

    /*
     NSC - Non Special Characters
     UCR - Unicode Characters Removed
     RWR - Redundant Whitespaces Removed
     */

    func NSC_UCR_RWR_map() -> [String] {
        let components = self.components(separatedBy: .whitespaces)
        var result = [String]()

        for component in components {
            guard component.count > 0 else {
                continue
            }

            // partialResult là một tuple gồm 2 thành phần kiểu String có tên accentedComponent và nonAccentedComponents
            let nonAccentedStringResult = component.reduce("") { partialResult, char in

                var nextPartialResult = ""
                if char.isLetter {
                    // Kiểm tra nếu chữ cái có dấu
                    switch char {
                    case "á", "à", "ả", "ã", "ạ", "ă", "ắ", "ằ", "ẳ", "ẵ", "ặ", "â", "ấ", "ầ", "ẩ", "ẫ", "ậ":
                        nextPartialResult = partialResult+"a"
                    case "Á", "À", "Ả", "Ã", "Ạ", "Ă", "Ắ", "Ằ", "Ẳ", "Ẵ", "Ặ", "Â", "Ấ", "Ầ", "Ẩ", "Ẫ", "Ậ":
                        nextPartialResult = partialResult+"A"
                    case "é", "è", "ẻ", "ẽ", "ẹ", "ê", "ế", "ề", "ể", "ễ", "ệ":
                        nextPartialResult = partialResult+"e"
                    case "É", "È", "Ẻ", "Ẽ", "Ẹ", "Ê", "Ế", "Ề", "Ể", "Ễ", "Ệ":
                        nextPartialResult = partialResult+"E"
                    case "ó", "ò", "ỏ", "õ", "ọ", "ô", "ố", "ồ", "ổ", "ỗ", "ộ", "ơ", "ớ", "ờ", "ở", "ỡ", "ợ":
                        nextPartialResult = partialResult+"o"
                    case "Ó", "Ò", "Ỏ", "Õ", "Ọ", "Ô", "Ố", "Ồ", "Ổ", "Ỗ", "Ộ", "Ơ", "Ớ", "Ờ", "Ở", "Ỡ", "Ợ":
                        nextPartialResult = partialResult+"O"
                    case "í", "ì", "ỉ", "ĩ", "ị":
                        nextPartialResult = partialResult+"i"
                    case "Í", "Ì", "Ỉ", "Ĩ", "Ị":
                        nextPartialResult = partialResult+"I"
                    case "ú", "ù", "ủ", "ũ", "ụ", "ư", "ứ", "ừ", "ử", "ữ", "ự":
                        nextPartialResult = partialResult+"u"
                    case "Ú", "Ù", "Ủ", "Ũ", "Ụ", "Ư", "Ứ", "Ừ", "Ử", "Ữ", "Ự":
                        nextPartialResult = partialResult+"U"
                    case "ý", "ỳ", "ỷ", "ỹ", "ỵ":
                        nextPartialResult = partialResult+"y"
                    case "Ý", "Ỳ", "Ỷ", "Ỹ", "Ỵ":
                        nextPartialResult = partialResult+"Y"
                    case "đ":
                        nextPartialResult = partialResult+"d"
                    case "Đ":
                        nextPartialResult = partialResult+"D"
                    default:
                        // Các trường hợp còn lại là chữ cái không có dấu
                        // Kiểm tra nếu có trường hợp ngoài mong muốn
                        nextPartialResult = partialResult+String(char)
                    }
                }
                else if "0" ... "9" ~= char {
                    nextPartialResult = partialResult+String(char)
                }
                else {
                    return partialResult
                }

                return nextPartialResult
            }
            if !nonAccentedStringResult.isEmpty {
                result.append(nonAccentedStringResult)
            }
        }
        return result
        /*
         Kết quả kiểm thử (Lưu ý chuỗi không xuống dòng!):
         "Dương Xuân Huy" -> ["Duong", "Xuan", "Huy"]
         "Duong Xuan Huy" -> ["Duong", "Xuan". "Huy"]
         "Dương1 Xuân2 Huy3 1609" -> ["Duong1", "Xuan2", "Huy3", "1609"]
         "Duong1 Xuan2 Huy3 1609" -> ["Duong1", "Xuan2", "Huy3", "1609"]
         #"~!@#$%^&*()_+{}|:"<>?`-=[]\;',./       ~!@#$%^&*()_+',./Dương1{}|:"<>?`-=[]\;            ~!@#$%^&*()_+{}|:"<>?`-=[]\;',./    ~!@#$%^&*()_+',./Xuân2{}|:"<>?`-=[]\;    ~!@#$%^&*()_+{}|:"<>?`-=[]\;',./     ~!@#$%^&*()_+',./Huy3{}|:"<>?`-=[]\;           ~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;16092002~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;           ~!@#$%^&*()_+',./Xuân1{}|:"<>?`-=[]\;"# -> ["Duong1", "Xuan2", "Huy3", "Xuan116092002Xuan1", "Xuan1"]
         */
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
}
