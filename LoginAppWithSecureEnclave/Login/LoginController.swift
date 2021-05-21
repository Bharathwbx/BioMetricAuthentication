import UIKit
import Firebase

class LoginController: UIViewController {
    
    let userNameTextField: UITextField = {
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
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onClickLoginButton), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up.", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 149, green: 204, blue: 244)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    let biometrics = Biometrics()
    let keyChain = Keychain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        clearKeyChainValues()
        initializeFields()
    }
    
    func initializeFields() {
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        setupDontHaveAccountButton()
        setupInputTextFields()
        if isBiometricEnabled {
            updateLogInButton()
        }
    }
    
    func clearKeyChainValues() {
        keyChain.deleteAllEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearTextFields()
        if isBiometricEnabled {
            updateLogInButton()
        }
    }
    
    var isBiometricEnabled: Bool {
        return (keyChain.string(forKey: Keychain.Keys.isEnabledBiometric) != nil)
    }
    
    func updateLogInButton() {
        switch biometrics.supportedType {
        case .faceID:
            loginButton.setTitle("Log in with Face ID", for: .normal)
        case .touchID:
            loginButton.setTitle("Log in with Touch ID", for: .normal)
        case .none:
            loginButton.setTitle("Login", for: .normal)
        }
        updateLoginButton(with: true)
    }
        
    private func clearTextFields() {
        userNameTextField.text = ""
        passwordTextField.text = ""
    }
    
    private func setupInputTextFields() {
        let stackView = UIStackView(arrangedSubviews: [userNameTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupDontHaveAccountButton() {
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 50)
    }
    
    @objc private func handleTextInputChange() {
        let isFormValid = userNameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        updateLoginButton(with: isFormValid)
    }
    
    func updateLoginButton(with isEnable: Bool) {
        if isEnable {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc private func onClickLoginButton() {
        if isBiometricEnabled && loginButton.titleLabel?.text != "Login" {
            loginWithBiometricAuthentication()
        } else {
            loginWithUserEnteredDetails()
        }
    }
    
    func loginWithBiometricAuthentication() {
        do {
            let result = try keyChain.readDetailsFromSecureEnclave(Keychain.Keys.secureEnclaveAccessKey)
            if let emailId = result?[Keychain.Keys.emailIdKey] as? String,
                let password = result?[Keychain.Keys.passwordKey] as? String {
                self.handleLogin(emailId: emailId, password: password)
            }else {
                self.showErrorAlert(with: "Login Failed", message: "Biometric is not matching.")
            }
        } catch let error {
            self.showErrorAlert(with: "Authentication Failed", message: error.localizedDescription)
        }
    }
    
    func loginWithUserEnteredDetails() {
        let emailId = userNameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        self.handleLogin(emailId: emailId, password: password)
    }
    
    func handleLogin(emailId: String, password: String) {
        Auth.auth().signIn(withEmail: emailId, password: password) { (user, err) in
            if let err = err {
                print("Failed to sign in with email...", err)
                self.showErrorAlert(with: "Failed to login", message: err.localizedDescription)
                return
            }
            print("Successfully Logged in with user", user?.user.uid ?? "")
            let welcomeController = WelcomeController()
            welcomeController.modalPresentationStyle = .fullScreen
            self.present(welcomeController, animated: true)
        }
    }
    
    private func showErrorAlert(with title: String, message: String? = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
    }
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
}


extension LoginController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
