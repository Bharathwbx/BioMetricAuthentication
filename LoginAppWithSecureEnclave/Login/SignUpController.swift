//
//  SignUpController.swift
//  LoginApp
//
//  Created by Bharatraj Rai on 7/15/20.
//  Copyright © 2020 Bharatraj Rai. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpController: UIViewController {
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.autocapitalizationType = .none
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 149, green: 204, blue: 244)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(closeSignUpController), for: .touchUpInside)
        return button
    }()

    let biometricImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "faceID")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(enrollBiometric), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let enrolBiometricButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enroll Biometric", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(enrollBiometric), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    let biometrics = Biometrics()
    let keyChain = Keychain()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        setupAlreadyHaveAccountButton()
        setupInputFields()
        setupBiometricEnrolOption()
    }
    
    private func setupAlreadyHaveAccountButton() {
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 50)
    }
    
    private func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signupButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150).isActive = true
//        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupBiometricEnrolOption() {
        view.addSubview(enrolBiometricButton)
        view.addSubview(biometricImageButton)

        enrolBiometricButton.anchor(top: nil, left: view.leftAnchor, bottom: alreadyHaveAccountButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 50)
        
        biometricImageButton.anchor(top: nil, left: view.leftAnchor, bottom: enrolBiometricButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

    }
    
    @objc func enrollBiometric() {
        guard let emailId = emailTextField.text, let password = passwordTextField.text else { return }
        var dict: [String:String] = [:]
        dict[Keychain.Keys.emailIdKey] = emailId
        dict[Keychain.Keys.passwordKey] = password
        let isSaved = keyChain.saveDataInSecureEnclave(Keychain.Keys.secureEnclaveAccessKey, dict: dict)
        if isSaved {
            _ = keyChain.set(string: "true", forKey: Keychain.Keys.isEnabledBiometric)
        }
        closeSignUpController()
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        if isFormValid {
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            DispatchQueue.main.async {
                if let err = error {
                    self.showAlert(with: "Failed to create user:", message: err.localizedDescription)
                    return
                }
                self.showAlert(with: "\(email) saved successfully.")
                self.updateBiometricImage()
                self.biometricImageButton.isHidden = false
                self.enrolBiometricButton.isHidden = false
            }
        }
    }
    
    private func updateBiometricImage() {
        switch biometrics.supportedType {
        case .faceID:
            self.biometricImageButton.setImage(UIImage(named: "faceID")?.withRenderingMode(.alwaysOriginal), for: .normal)
        case .touchID:
            self.biometricImageButton.setImage(UIImage(named: "touchID")?.withRenderingMode(.alwaysOriginal), for: .normal)
        case .none:
            self.biometricImageButton.setImage(UIImage(named: "touchID")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    private func showAlert(with title: String, message: String? = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
    }
    
    @objc func closeSignUpController() {
        navigationController?.popViewController(animated: true)
    }
}

extension SignUpController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
