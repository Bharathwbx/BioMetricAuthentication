import Foundation
import LocalAuthentication

class Keychain {

    private let SERVICE = "CNBMobileKeychainService"
    
    @discardableResult func saveDataInSecureEnclave(_ key: String, dict:[String: Any]) -> Bool {
        if deleteEntry(forKey: key) {
//            let userSessionData: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
            do {
                let userSessionData: Data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
                
                let access = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .userPresence, nil)
                let query: [String: Any] = [String(kSecClass): kSecClassGenericPassword,
                                            String(kSecAttrService): self.SERVICE,
                                            String(kSecAttrAccount): key,
                                            String(kSecAttrAccessControl): access as Any,
                                            String(kSecValueData): userSessionData ]
                let status = SecItemAdd(query as CFDictionary, nil)
                return (status == errSecSuccess)
            } catch {
                print("Error occured while archiving user details", error)
                return false
            }
        } else {
            return false
        }
    }
    
    @discardableResult func deleteEntry(forKey key: String) -> Bool {

        let query: NSDictionary = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrService): self.SERVICE,
            String(kSecAttrAccount): key
        ]

        let status = SecItemDelete(query as CFDictionary)

        return (status == errSecSuccess || status == errSecItemNotFound)
    }
    
    func readDetailsFromSecureEnclave(_ key:String) throws -> [String: Any]? {
        let query: [String: Any] = [String(kSecClass): kSecClassGenericPassword,
                                    String(kSecAttrService): self.SERVICE,
                                    String(kSecAttrAccount): key,
                                    String(kSecMatchLimit): kSecMatchLimitOne,
                                    String(kSecReturnAttributes): true,
                                    String(kSecUseOperationPrompt): "Use Touch ID to log in",
                                    String(kSecReturnData): true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
        guard let userDataItem = item as? [String: Any],
            let userData = userDataItem[kSecValueData as String] as? Data else {
                return nil
        }
        guard let dictionary = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(userData) as? [String: Any] else { return nil }
        
        return dictionary
    }
    
    func set(data: Data, forKey key: String) -> Bool {
        
        if self.deleteEntry(forKey: key) {
            
            let query: NSMutableDictionary = [
                String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                String(kSecClass): kSecClassGenericPassword,
                String(kSecUseAuthenticationUI): kSecUseAuthenticationUIAllow,
                String(kSecAttrService): self.SERVICE,
                String(kSecAttrAccount): key,
                String(kSecValueData): data
            ]
            
            let status = SecItemAdd(query, nil)
            
            return (status == errSecSuccess)
        }
        
        return false
    }
    
    func set(string: String, forKey key: String) -> Bool {
        
        if let data = string.data(using: .utf8, allowLossyConversion: false) {
            
            return self.set(data: data, forKey: key)
        }
        
        return false
    }
    
    func data(forKey key: String) -> Data? {
        
        let query: NSMutableDictionary = [
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            String(kSecMatchLimit): kSecMatchLimitOne,
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrService): self.SERVICE,
            String(kSecAttrAccount): key,
            String(kSecReturnData): kCFBooleanTrue as Any
        ]
        
        var data: AnyObject?
        let status = withUnsafeMutablePointer(to: &data) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            
            return data as? Data
        }
        
        return nil
    }
    
    func string(forKey key: String) -> String? {
        
        if let data = self.data(forKey: key) {
            
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    func deleteAllEntries() {
        let query: NSDictionary = [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecAttrService): self.SERVICE
        ]

        SecItemDelete(query as CFDictionary)
    }
    
    func getDictionary(forKey key: String) -> [String: String]? {
        if let data = data(forKey: key) {
            // Convert Data to Dictionary
            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return dict
            }
        }
        return nil
    }
    
    func saveDictionary(_ dict: [String: Any]) {
        dict.forEach { (arg) in
            let (key, value) = arg
            if let val = value as? String {
                _ = set(string: val, forKey: key)
            } else if value is [String: String], let jsonData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                _ = set(data: jsonData, forKey: key)
            } else {
                print("Failed to Save Value forKey: \(key)")
            }
        }
    }
}

extension Keychain {
    
    struct Keys {
        static var emailIdKey: String { return "emailIdKey" }
        static var passwordKey: String { return "passwordKey" }
        static var isEnabledBiometric: String { return "isEnabledBiometric" }
        static var quickLookKey: String { return "quickLook" }
        static var secureEnclaveAccessKey: String { return "secureEnclaveAccessKey"}
    }
    
}

struct KeychainError: Error {
    var status: OSStatus
    
    var localizedDescription: String {
        if #available(iOS 11.3, *) {
            return SecCopyErrorMessageString(status, nil) as String? ?? ""
        } else {
            return "Error occurred in Keychain."
        }
    }
}
