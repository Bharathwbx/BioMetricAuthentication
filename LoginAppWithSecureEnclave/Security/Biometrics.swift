//
//  Biometrics.swift
//  LoginApp
//
//  Created by Bharatraj Rai on 7/16/20.
//  Copyright © 2020 Bharatraj Rai. All rights reserved.
//

import LocalAuthentication

enum BiometricType: Int {
    case none
    case touchID
    case faceID
}

class Biometrics {
    
    var supportedType: BiometricType {
        let authContext = LAContext()
        var error: NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            return authContext.biometryType == .faceID ? .faceID : .touchID
        }
        return .none
    }
    
    func isBiometricOrPasscodeEnabled() -> Bool {
        return supportedType != .none || LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }
    
    func isBiometricEnabled() -> Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
}
