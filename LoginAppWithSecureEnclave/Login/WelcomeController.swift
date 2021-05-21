//
//  WelComeController.swift
//  LoginApp
//
//  Created by Bharatraj Rai on 7/15/20.
//  Copyright © 2020 Bharatraj Rai. All rights reserved.
//

import UIKit
import Firebase

class WelcomeController: UIViewController {
    
    let greetContainerView: UIView = {
        let view = UIView()
        
        let greetImageView = UIImageView(image: UIImage(named: "Greet"))
        greetImageView.contentMode = .scaleAspectFit

        view.addSubview(greetImageView)
        greetImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 200)
        greetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        greetImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "You have successfully logged in."
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(logoutButton)
        logoutButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(greetContainerView)
        greetContainerView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 30, paddingBottom: 50, paddingRight: 30, width: 0, height: 200)
        view.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error occured while logging out.", error)
        }
        dismiss(animated: true, completion: nil)
    }
}
