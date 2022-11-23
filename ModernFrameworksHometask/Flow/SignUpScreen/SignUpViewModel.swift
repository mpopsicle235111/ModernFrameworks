//
//  SignUpViewModel.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 20.11.2022.
//

import Foundation

class SignUpViewModel {
    weak var appCoordinator: AppCoordinator?
    
    func goToLoginScreen() {
        appCoordinator?.goToLoginPage()
    }
}
