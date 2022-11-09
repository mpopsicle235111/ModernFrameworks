//
//  LoginViewModel.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import Foundation

class LoginViewModel {
    weak var appCoordinator: AppCoordinator?
    
    func goToMapScreen() {
        appCoordinator?.goToMapPage()
    }
}
