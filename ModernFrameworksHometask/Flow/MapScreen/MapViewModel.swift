//
//  MapViewModel.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import Foundation

class MapViewModel {
    weak var appCoordinator: AppCoordinator?
    
    func logout() {
        appCoordinator?.goToLoginPage(isLogout: true)
    }
}
