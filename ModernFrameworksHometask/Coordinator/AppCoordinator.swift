//
//  AppCoordinator.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import UIKit

//This class is controlled by AppDelegate
class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigation: UINavigationController
    
    //We could have initialized some ViewController here,
    //but let's just work with the SToryboard instead
    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
    
    init(navigationController: UINavigationController){
        self.navigation = navigationController
    }
    
    func start() {
        goToLoginPage()
    }
    
    func goToLoginPage(isLogout: Bool = false) {
        if isLogout {
            navigation.popViewController(animated: true)
            return
        }
        
        instantiateLoginViewController()
    }
    
    private func instantiateLoginViewController() {
        //Let's check if we have a loginViewController
        guard let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        //If we have created a LoginViewController succesfully,
        //let's create a LoginViewModel
        let loginViewModel = LoginViewModel()
        loginViewModel.appCoordinator = self
        loginViewController.viewModel = loginViewModel
        navigation.pushViewController(loginViewController, animated: true)
    }
    
    func goToMapPage() {
        //Let's check if we have an mapViewController
        guard let mapViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            return
        }
        //If we have created an MapViewController succesfully,
        //let's create a MapViewModel
        let mapViewModel = MapViewModel()
        mapViewModel.appCoordinator = self
        mapViewController.viewModel = mapViewModel
        navigation.pushViewController(mapViewController, animated: true)
        
    }
}
