//
//  MainViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/18/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var m_btnStart: UIView!
    @IBOutlet weak var m_btnScore: UIView!
    @IBOutlet weak var m_btnLogin: UIView!
    @IBOutlet weak var m_btnExit: UIView!
    @IBOutlet weak var m_btnAbout: UIView!
    @IBOutlet weak var m_btnHelp: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBorderLine(view: m_btnStart)
        self.addBorderLine(view: m_btnScore)
        self.addBorderLine(view: m_btnLogin)
        self.addBorderLine(view: m_btnExit)
        self.addBorderLine(view: m_btnAbout)
        self.addBorderLine(view: m_btnHelp)
        
        self.addViewCornor(view: m_btnStart)
        self.addViewCornor(view: m_btnScore)
        self.addViewCornor(view: m_btnLogin)
        self.addViewCornor(view: m_btnExit)
        self.addViewCornor(view: m_btnAbout)
        self.addViewCornor(view: m_btnHelp)
        
        
        let recogStart = UITapGestureRecognizer(target: self, action: #selector(self.TapStart))
        m_btnStart.isUserInteractionEnabled = true
        m_btnStart.addGestureRecognizer(recogStart)
        
        let recogScore = UITapGestureRecognizer(target: self, action: #selector(self.TapScore))
        m_btnScore.isUserInteractionEnabled = true
        m_btnScore.addGestureRecognizer(recogScore)
        
        let recogLogin = UITapGestureRecognizer(target: self , action: #selector(self.TapLogin))
        m_btnLogin.isUserInteractionEnabled = true
        m_btnLogin.addGestureRecognizer(recogLogin)
        
        let recogExit = UITapGestureRecognizer(target: self, action: #selector(self.TapExit))
        m_btnExit.isUserInteractionEnabled = true
        m_btnExit.addGestureRecognizer(recogExit)
        
        let recogAbout = UITapGestureRecognizer(target: self, action: #selector(self.TapAbout))
        m_btnAbout.isUserInteractionEnabled = true
        m_btnAbout.addGestureRecognizer(recogAbout)
        
        let recogHelp = UITapGestureRecognizer(target: self, action: #selector(self.TapHelp))
        m_btnHelp.isUserInteractionEnabled = true
        m_btnHelp.addGestureRecognizer(recogHelp)
        
    }
    
    @objc func TapStart() {
        let gameVC = storyboard?.instantiateViewController(withIdentifier:"gameVC")as! GameViewController
        present(gameVC, animated: false, completion: nil)
    }
    @objc func TapScore() {
        let scoreVC = storyboard?.instantiateViewController(withIdentifier: "scoreVC")as! HighScoreViewController
        present(scoreVC, animated: false, completion: nil)
    }
    
    @objc func TapLogin() {
        let loginController = storyboard?.instantiateViewController(withIdentifier: "loginVC")as! LoginViewController
        present(loginController, animated: false , completion: nil)
    }
    
    @objc func TapExit() {
        self.dismiss(animated: false , completion: nil)
        exit(0);
    }
    
    @objc func TapAbout(){
        let aboutController = storyboard?.instantiateViewController(withIdentifier: "aboutVC")as!AboutViewController
        present(aboutController, animated: false, completion: nil)
    }
    
    @objc func TapHelp() {
        let helpController = storyboard?.instantiateViewController(withIdentifier: "helpVC")as! HelpViewController
        present(helpController, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addTextBorder (textField: UITextField){
        let border = CALayer()
        let width = CGFloat(1.0)
        
        border.borderColor = UIColor.gray.cgColor
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
}
