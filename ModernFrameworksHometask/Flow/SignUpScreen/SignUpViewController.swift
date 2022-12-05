//
//  SignUpViewController.swift
//  ModernFrameworksHometask
//
//  Created by Anton Lebedev on 20.11.2022.
//  CoreData login storage by Gagan_iOS,
//  https://stackoverflow.com/questions/35064464/login-signup-ios-swift-core-data

import UIKit
import CoreData
import CommonCrypto

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userLogin: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userPasswordRetyped: UITextField!
    
    //Added for Navigation Coordinator
    var viewModel: SignUpViewModel?

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
    
    func presentAlert(alertTitle: String, alertMessage: String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "CANCEL", style: .default, handler: nil)

        alert.addAction(ok)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func register(_ sender: UIButton) {
        if userLogin.text == "" || userPassword.text == "" || userPasswordRetyped.text == ""
        {
            presentAlert(alertTitle: "Information", alertMessage: "Please fill in all the fields")
        }

        else if (userPassword.text != userPasswordRetyped.text)
        {
            presentAlert(alertTitle: "Information", alertMessage: "Your password does not match")
        }

        else
        {
                let app = UIApplication.shared.delegate as! AppDelegate

                let context = app.persistentContainer.viewContext

                let new_user = NSEntityDescription.insertNewObject(forEntityName: "LoginDetails", into: context)
                
                //Added to encrypt the login and the password
                let cryptedUserLogin = userLogin.text?.sha1()
                let cryptedUserPassword = userPassword.text?.sha1()
            
                 
                print("=============")
                print(cryptedUserLogin)
                print(cryptedUserPassword)
                print("=============")
                
                //Was before, not encrypted
                //new_user.setValue(userLogin.text, forKey: "userLogin")
                //new_user.setValue(userPassword.text, forKey: "userPassword")
                //Now:
                new_user.setValue(cryptedUserLogin, forKey: "userLogin")
                new_user.setValue(cryptedUserPassword, forKey: "userPassword")

                do
                {
                    try context.save()
                    print("REGISTRATION SUCCESSFUL")
                }
                catch
                {
                    let Fetcherror = error as NSError
                    print("error", Fetcherror.localizedDescription)
                }
            }
            //Navigation
            viewModel?.goToLoginScreen()
            //self.navigationController?.popViewController(animated: true)

            }
    }
    
///This method is added to enable sha1 encryption
extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
