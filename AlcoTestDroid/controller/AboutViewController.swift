//
//  AboutViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/19/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var m_btnReturn: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBorderLine(view: m_btnReturn)
        self.addViewCornor(view: m_btnReturn)
        
        let recogReturn = UITapGestureRecognizer(target: self, action: #selector(self.tapReturn))
        m_btnReturn.isUserInteractionEnabled = true
        m_btnReturn.addGestureRecognizer(recogReturn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func tapReturn() {
        self.dismiss(animated: false, completion: nil)
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
