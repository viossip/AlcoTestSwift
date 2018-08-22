//
//  LoginViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/19/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var m_btnSignin: UIView!
    @IBOutlet weak var m_btnGetAccount: UIView!
    @IBOutlet weak var m_btnSignOut: UIView!
    @IBOutlet weak var m_btnRegister: UIView!
    
    @IBOutlet weak var tv_Email: UITextField!
    @IBOutlet weak var tv_Password: UITextField!
    @IBOutlet weak var tv_Username: UITextField!
    
    @IBOutlet weak var lb_sign: UILabel!
    @IBOutlet weak var lb_Account: UILabel!
    @IBOutlet weak var lb_signout: UILabel!
    @IBOutlet weak var lb_Register: UILabel!
    
    var mCredential:AuthCredential!
    var b_accept: Bool!
    var strExpireDate: String!

    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        m_btnRegister.isHidden = true
        lb_Register.isHidden = true
        tv_Username.isHidden = true
        
        self.addViewCornor(view: m_btnSignin)
        self.addViewCornor(view: m_btnSignOut)
        self.addViewCornor(view: m_btnGetAccount)
        self.addViewCornor(view: m_btnRegister)
        
        self.addBorderLine(view: m_btnSignin)
        self.addBorderLine(view: m_btnSignOut)
        self.addBorderLine(view: m_btnGetAccount)
        self.addBorderLine(view: m_btnRegister)
        
        tv_Email.textColor = UIColor.white
        tv_Password.textColor = UIColor.white
        tv_Username.textColor = UIColor.white
        
        self.addPlaceHolder(Name: "Email", textfield: tv_Email)
        self.addPlaceHolder(Name: "Password", textfield: tv_Password)
        self.addPlaceHolder(Name: "UserName", textfield: tv_Username)
        
        self.addTextBorder(textField: tv_Email)
        self.addTextBorder(textField: tv_Password)
        self.addTextBorder(textField: tv_Username)
    
        let recogSignin = UITapGestureRecognizer(target: self, action: #selector(self.tapSignin))
        m_btnSignin.isUserInteractionEnabled = true
        m_btnSignin.addGestureRecognizer(recogSignin)
        
        let recogAccount = UITapGestureRecognizer(target: self, action: #selector(self.tapGetAccount))
        m_btnGetAccount.isUserInteractionEnabled = true
        m_btnGetAccount.addGestureRecognizer(recogAccount)
        
        let recogSignOut = UITapGestureRecognizer(target: self, action: #selector(self.tapSignOut))
        m_btnSignOut.isUserInteractionEnabled = true
        m_btnSignOut.addGestureRecognizer(recogSignOut)
        
        let recogRegister = UITapGestureRecognizer(target: self, action: #selector(self.TapReigster))
        m_btnRegister.isUserInteractionEnabled = true
        m_btnRegister.addGestureRecognizer(recogRegister)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addTextBorder (textField: UITextField){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x:0, y:textField.frame.size.height - width,width: textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func addViewCornor (view:UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6.0
    }
    
    func addBorderLine(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
    }
    func addPlaceHolder(Name: String, textfield: UITextField) {
        
        let textAttributes = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)]
            as [NSAttributedStringKey : Any]
        let placeHolder = NSAttributedString(string: Name,attributes:textAttributes)
        
        textfield.attributedPlaceholder = placeHolder
    }
    
    @objc func tapSignin() {
        let email = tv_Email.text!
        let pass = tv_Password.text!
        UserDefaults.standard.set("name", forKey: email)
        let str = "abc"
        if(Invalide_Email(param1:email, param2:pass,param3: str)){
//            let hudWait = MBProgressHUD.showAdded(to: self.view, animated: true)
//            hudWait.label.text = "Please Wait.."
            Auth.auth().signIn(withEmail: email, password: pass) {
                (user, error) in
                if error == nil {
                    let ref = Database.database().reference().child("Users/users").child(Auth.auth().currentUser!.uid)
                    ref.updateChildValues(["email": email])
                    ref.updateChildValues(["password":pass])
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(pass, forKey: "password")
                    let expireDate : Date = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd"
                    self.strExpireDate = dateformatter.string(from: expireDate)
                    ref.observe(DataEventType.value, with: {(snapshot) in
                        if snapshot.childrenCount > 0 {
                            for child in snapshot.children.allObjects as! [DataSnapshot] {
                                let childObject = child.value as? [String: AnyObject]
                                if (childObject?["expireDate"] == nil) {
                                    ref.child("expireDate").setValue(self.strExpireDate)
                                } else {
                                    self.strExpireDate = childObject?["expireDate"] as! String
                                    UserDefaults.standard.set("name", forKey: email)
                                    let uid = Auth.auth().currentUser?.uid
                                    UserDefaults.standard.set("uid", forKey: uid!)
                                }
                            }
                            UserDefaults.standard.set(self.strExpireDate, forKey: "expireDate")
                        }
                        self.dismiss(animated: false, completion: nil);
//                        MBProgressHUD.hide(for: self.view, animated: false)
                    })
                    
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    UserDefaults.standard.set("name", forKey: email)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
//                  MBProgressHUD.hide(for: self.view, animated: false)
                }
            }
        }
    }
    
    @objc func tapGetAccount() {
        
        m_btnRegister.isHidden = false
        lb_Register.isHidden = false
        tv_Username.isHidden = false
        
        m_btnSignin.isHidden = true
        m_btnSignOut.isHidden = true
        m_btnGetAccount.isHidden = true
        
        lb_sign.isHidden = true
        lb_Account.isHidden = true
        lb_signout.isHidden = true
    }
    
    @objc func TapReigster(){
        
        let email = tv_Email.text!
        let pass = tv_Password.text!
        let name = tv_Username.text!
        
        if (Invalide_Email(param1:email, param2:pass, param3:name)) {
//            let hudWait = MBProgressHUD.showAdded(to: self.view, animated: true)
//            hudWait.label.text = "Please Wait.."
            Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                if error == nil {
                    print("You have successfully signed up")
                    let ref = Database.database().reference().child("Users/users").child(Auth.auth().currentUser!.uid)
                    ref.updateChildValues(["name": name])
                    ref.updateChildValues(["email":email])
                    ref.updateChildValues(["password":pass])
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
//                    MBProgressHUD.hide(for: self.view, animated: false)
                }
            }
        }
    }
    
    @objc func tapSignOut() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func Invalide_Email(param1:String, param2:String, param3:String) -> Bool{
        
        if (param1.count == 0 && param2.count == 0 && param3.count == 0){
            alertShow(string: "Please Insert your profile details!")
        }else if(param2.count <= 4){
            alertShow(string: "Please insert password more than 4 characters!")
        }else if(isValidEmail(testStr: param1) == false){
            alertShow(string: "Invalide Email!")
        }else if(param3.count == 0){
           alertShow(string: "Please Insert your Full Name!")
        }else{
//            LogIn(email:param1, password: param2)
            if(param3 == "abc"){
                ToastHelper.showToast(view: self.view, message: "Login Success!")
                self.dismiss(animated: false, completion: nil)
                return true
            }else{
                m_btnRegister.isHidden = true
                lb_Register.isHidden = true
                tv_Username.isHidden = true
                
                m_btnSignin.isHidden = false
                m_btnSignOut.isHidden = false
                m_btnGetAccount.isHidden = false
                
                lb_sign.isHidden = false
                lb_Account.isHidden = false
                lb_signout.isHidden = false
                
                tv_Email.text = ""
                tv_Password.text = ""
                tv_Username.text = ""
                
                ToastHelper.showToast(view: self.view, message: "Register Success!")
                
                return true
            }
        }
        return false
    }
    func alertShow(string:String){
        let alert = UIAlertController(title: "Warnning!", message: string, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
}
