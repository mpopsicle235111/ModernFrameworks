//
//  LoginViewController.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 09.11.2022.
//
//  New login CoreData routine by Gagan_iOS,
//  https://stackoverflow.com/questions/35064464/login-signup-ios-swift-core-data

import UIKit
import CoreData
import CommonCrypto
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    //In RX version we add a button Outlet, so we can change the button's color
    //This is no Action outlet! Action outlet is below.
    @IBOutlet weak var loginButton: UIButton!
    //We also add a DisposeBag in RX version:
    private let disposeBag = DisposeBag()
    //These are default values for PublishSubject - we need these, because
    //LoginViewModel - and our viewModel - is Optional
    var loginInputText = PublishSubject<String>()
    var passwordInputText = PublishSubject<String>()
    
    //Added for navigation
    var viewModel: LoginViewModel?
    
    //Added for CoreData
    var result = NSArray()
    
    
    
    //As soon, as the keyboard is shown
    @objc func keyboardWasShown(notification: Notification) {
        //We receive keyboard size
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        //print(kbSize.height)
        
        //Add an inset below the UIScrollView, equal to keyboard size
        self.scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
        
    //As soon, as the keyboard is hidden
    @objc func keyboardWillBeHidden (notification: Notification) {
        //We set a zero inset below the UIScrollView
        let contentInsets = UIEdgeInsets.zero
        scrollView?.contentInset = contentInsets
    }
    
    //Hide keyboard, when the empty place on screen is tapped
    @objc func hideKeyboard() {
            self.scrollView?.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Let's add tap gesture to UISCrollView
        //This is the gesture
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //Assign the gesture to UIScrollView
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
        
        //Added for RX login
        //Let's allow for the loginTextField to see the keyboard straight away
        loginInput.becomeFirstResponder()
        //Let's map the strings to non-optional and bind it to LoginViewModel
        loginInput.rx.text.map { $0 ?? "" }.bind(to: viewModel?.loginInputTextPublishSubject ?? loginInputText).disposed(by: disposeBag)
        passwordInput.rx.text.map { $0 ?? "" }.bind(to: viewModel?.passwordInputTextPublishSubject ?? passwordInputText).disposed(by: disposeBag)
        //Then we bind our valid observable to a loginButton
        viewModel?.isValid().bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        //And we also bind in to alpha (color saturation) property:
        //is isv`alid, then Opacity = 1, if not valid, then opacity is 0.9Admin
        viewModel?.isValid().map { $0 ? 1 : 0.9 }.bind(to: loginButton.rx.alpha).disposed(by: disposeBag)
        
    }
    
    //Added for CoreData
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //In viewWillAppear we subscribe to the messages from keboard.
    //The keyboard issues these messages in the notification centre.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //We subscribe to two messages:
        //The first comes, when the keyboard is shown
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        //The second comes, when the keyboard is hidden
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    //GeekBrains teaches us to unsubscribe from messages not necessary anymore.
    //We do this in viewWillDisappear (when LoginViewController disappears).
    override func viewWillDisappear (_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    @IBAction func didTapSignUp(_ sender: UIButton) {
        viewModel?.goToSignUpScreen()
    }
    
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        
        //MARK: password test values
        //Login template: Admin1, Admin2, Admin3...
        //Password always: 1234
        
        //Acquire login string
        let login = loginInput.text!
        //Acquire password string
        let password = passwordInput.text!
        //Compare to the stored login and password
        print("RECEIVED LOGIN: \(login)")
        print("RECEIVED PASSWORD: \(password)")
        
        //Added to encrypt the login and the password
        let cryptedUserLogin = loginInput.text?.sha2()
        let cryptedUserPassword = passwordInput.text?.sha2()
    
        print("Crypted Login And Password")
        print("=============")
        print(cryptedUserLogin)
        print(cryptedUserPassword)
        print("=============")
        
        
        if loginInput.text == "" || passwordInput.text == ""
            {
                
                let alert = UIAlertController(title: "ERROR", message: "Please fill in both login and password", preferredStyle: .alert)

                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: nil)

                alert.addAction(ok)
                alert.addAction(cancel)

                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                self.CheckForUserNameAndPasswordMatch(username : cryptedUserLogin ?? "", password : cryptedUserPassword ?? "")
            }
    }
        
    //CoreData check function
    func CheckForUserNameAndPasswordMatch(username: String, password : String)
    {
        let app = UIApplication.shared.delegate as! AppDelegate

        let context = app.persistentContainer.viewContext

        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LoginDetails")

        let predicate = NSPredicate(format: "userLogin = %@", username)
        
        
        //Wipe the textFields clean for the next attempt
        clearTextField(textField: loginInput)
        clearTextField(textField: passwordInput)
        
        fetchrequest.predicate = predicate
        do
        {
            result = try context.fetch(fetchrequest) as NSArray

            if result.count > 0
            {
                let objectentity = result.firstObject as! LoginDetails
                if objectentity.userLogin == username && objectentity.userPassword == password
                    {
                        print("LOGIN SUCCESSFUL")
                        viewModel?.goToMapScreen()
                    }
                else
                    {
                    print("Wrong username or password!")
                    //UIAlertController is a class that shows messages to the user
                    //Let's have this controller here to notify user, that his/her
                    //password is wrong. Otherwise the user may think, that
                    //something is wrong with the app, and we have to consider UX
                    let alert = UIAlertController(title: "ERROR", message: "Wrong username or password", preferredStyle: .alert)
                    //We create a special button so that the user can dismiss our pop-up
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    //and add this button to UIAlertcontroller
                    alert.addAction(action)
                    //Show UIAlertController
                    present(alert, animated: true, completion: nil)
                    }
                }
        }

        catch
        {
            let fetch_error = error as NSError
            print("error", fetch_error.localizedDescription)
        }

    }
    
    //Clean up the login and password textfiela after a failed attempt
    func clearTextField(textField: UITextField) {
        textField.text = ""
    }
    
    
        
     /* OLD PASSWORD CHECK SECTION
        if login == "Admin" && password == "1234" {
            print("ACCESS GRANTED")
            viewModel?.goToMapScreen()
            } else {
            print("ACCESS DENIED!")
            //UIAlertController is a class that shows messages to the user
            //Let's have this controller here to notify user, that his/her
            //password is wrong. Otherwise the user may think, that
            //something is wrong with the app, and we have to consider UX
            let alert = UIAlertController(title: "ERROR", message: "Wrong username or password", preferredStyle: .alert)
            //We create a special button so that the user can dismiss our pop-up
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            //and add this button to UIAlertcontroller
            alert.addAction(action)
            //Show UIAlertController
            present(alert, animated: true, completion: nil)
            }
    }
      */
    
}



///This method is added to enable sha1 encryption
extension String {
    func sha2() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
