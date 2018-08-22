//
//  HighScoreViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/24/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit
import Firebase

class HighScoreViewController: UIViewController {
    
    var databaseHandle: DatabaseHandle!
    var databaseRefer: DatabaseReference!
    
    @IBOutlet weak var m_btnReturn: UIView!
    @IBOutlet weak var gameType: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var type: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name  =  UserDefaults.standard.string(forKey: "name")
        self.name.text = name
        
        databaseHandle = Database.database().reference().child("Players/gameType").observe(.childAdded, with: {(data) in
            let type: String = (data.value as? String)!
            self.type.text = type;
        })
        
        databaseHandle = Database.database().reference().child("Players/time").observe(.childAdded, with: {(data) in
            let score: String = (data.value as? String)!
            self.score.text = score;
            let level:String = (data.value as? String)!
        })
        
        self.addBorderLine(view: m_btnReturn)
        self.addViewCornor(view: m_btnReturn)
        
        let recogReturn = UITapGestureRecognizer(target: self, action: #selector(self.TapReturn))
        m_btnReturn.isUserInteractionEnabled = true
        m_btnReturn.addGestureRecognizer(recogReturn)
    }
    
    @objc func TapReturn() {
        self.dismiss(animated: false, completion: nil)
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
