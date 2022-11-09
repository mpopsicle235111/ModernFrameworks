//
//  Coordinator.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import UIKit

protocol Coordinator {
    //This is a coordinator for the main (parent) view
    var parentCoordinator: Coordinator? { get set }
    //Children is an array of coordinators, i.e.
    //each additional controller has its own coordinator
    var children: [Coordinator] { get set }
    //Instead of segues we're going to use a Navigation Controller
    var navigation: UINavigationController { get set }
    //This method will start all this navigation process
    func start()
}
