//
//  LoginViewController.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import UIKit

class LoginViewController: UIViewController {
    var viewModel: LoginViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        viewModel?.goToMapScreen()
    }
    
}
