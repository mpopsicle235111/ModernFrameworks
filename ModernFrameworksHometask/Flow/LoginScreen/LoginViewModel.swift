//
//  LoginViewModel.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    weak var appCoordinator: AppCoordinator?
    
    //RX insert: we need to create binding between input and ViewModel,
    //and another binding, that goes vice versa, that will tell the ViewModel,
    //that this input is valid.
    //So we define two Publishers:
    let loginInputTextPublishSubject = PublishSubject<String>()
    let passwordInputTextPublishSubject = PublishSubject<String>()
    //Then we create an Observable, that checks, if both loginInput and passwordInput
    //together are valid
    func isValid() -> Observable<Bool> {
        return Observable.combineLatest(loginInputTextPublishSubject.asObservable().startWith(""), passwordInputTextPublishSubject.asObservable().startWith("")).map { login, password in
            //Login and password should be over 3 characters long
            return login.count > 3 && password.count > 3
        }.startWith(false)  //We have to start observing with some value
                            //so we add initial values for login, password
                            //and also for the isValid situation
    }
    
    func goToMapScreen() {
        appCoordinator?.goToMapPage()
    }
    
    func goToSignUpScreen() {
        appCoordinator?.goToSignUpScreen()
    }
}
