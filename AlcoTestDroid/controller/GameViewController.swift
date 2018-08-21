//
//  GameViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/19/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit
import CoreMotion
class GameViewController: UIViewController{
    
    var clickable = false
    let stableY:Double = 0.1
    let stableX:Double = 0.1
    
    @IBOutlet weak var m_btnSimple: UIView!
    @IBOutlet weak var m_btnAdvance: UIView!
    @IBOutlet weak var m_btnTraining: UIView!
    @IBOutlet weak var m_btnReturn: UIView!
    @IBOutlet weak var lb_Simple: UILabel!
    @IBOutlet weak var lb_Advance: UILabel!
    @IBOutlet weak var lb_Training: UILabel!
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //-------set the view properties
        
        self.addBorderLine(view: m_btnSimple)
        self.addBorderLine(view: m_btnAdvance)
        self.addBorderLine(view: m_btnTraining)
        self.addBorderLine(view: m_btnReturn)
        
        self.addViewCornor(view: m_btnSimple)
        self.addViewCornor(view: m_btnAdvance)
        self.addViewCornor(view: m_btnTraining)
        self.addViewCornor(view: m_btnReturn)
        
        //--------button click event
        
        let recogSimple = UITapGestureRecognizer(target: self, action: #selector(self.tapSimpleGame))
        m_btnSimple.isUserInteractionEnabled = true
        m_btnSimple.addGestureRecognizer(recogSimple)
        
        let recogAdvance = UITapGestureRecognizer(target: self, action: #selector(self.tapAdvaneGame))
        m_btnAdvance.isUserInteractionEnabled = true
        m_btnAdvance.addGestureRecognizer(recogAdvance)
        
        let recogTrain = UITapGestureRecognizer(target: self, action: #selector(self.tapTraining))
        m_btnTraining.isUserInteractionEnabled = true
        m_btnTraining.addGestureRecognizer(recogTrain)
        
        let recogReturn = UITapGestureRecognizer(target: self, action: #selector(self.tapReturn))
        m_btnReturn.isUserInteractionEnabled = true
        m_btnReturn.addGestureRecognizer(recogReturn)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data
            {
                
                
                let y = myData.acceleration.y
                let x = myData.acceleration.x
                let z = myData.acceleration.z
    
                let StateX:Bool = x <= self.stableX && x >= -self.stableX
                let StateY:Bool = y <= self.stableY && y >= -self.stableY
                let StateX_up:Bool = x >= self.stableX && x <= 0.1
                let StateX_down:Bool = x >= -0.1 && x < -self.stableX
                let StateY_left:Bool = y <= 0.1 && y > self.stableY
                let StateY_right:Bool = y >= -0.1 && y < -self.stableY
                let Loose:Bool = y > 0.1 || y < -0.1 || x > 0.1 || x < -0.1
                let StateButton:Bool = StateY && StateX
                
                if( StateX && StateY){
//                    print("Enable" , x , y ,z)
                    if(self.m_btnSimple.backgroundColor == UIColor .red){
                        self.clickable = false
                    }else{
                        self.clickable = true
                    }
                    
                    self.m_btnSimple.backgroundColor = UIColor.white
                    self.m_btnAdvance.backgroundColor = UIColor.white
                    self.m_btnTraining.backgroundColor = UIColor.white
                    
                    self.lb_Simple.textColor = UIColor.black
                    self.lb_Advance.textColor = UIColor.black
                    self.lb_Training.textColor = UIColor.black
                }else if(!StateX && !StateY){
                    self.lb_Simple.textColor = UIColor.white
                    self.lb_Advance.textColor = UIColor.white
                    self.lb_Training.textColor = UIColor.white
                    
                    self.m_btnSimple.backgroundColor = UIColor.red
                    self.m_btnAdvance.backgroundColor = UIColor.red
                    self.m_btnTraining.backgroundColor = UIColor.red
                    
                    self.clickable = false
                    if(StateX_up){
//                        print("Move to Up")
                    }
                    if(StateX_down){
//                        print("Move to Down")
                    }
                    if(StateY_left){
//                        print("Move to Left")
                    }
                    if(StateY_right){
//                        print("Move to Right")
                    }
                    if(Loose){
//                        print("Loose", x , y ,z)
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @objc func tapSimpleGame() {
        if(clickable){
            let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultVC") as! GameResultViewController
            resultVC.game_Level = 1;
            present(resultVC, animated: false, completion: nil)
        }else{
            alertShow(string: "Please stay your Phone Horizontally!")
        }
        
    }
    @objc func tapAdvaneGame() {
        if(clickable){
            let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultVC")as! GameResultViewController
            resultVC.game_Level = 2;
            present(resultVC, animated: false, completion: nil)
        }else{
            alertShow(string: "Please stay your Phone Horizontally!")
        }
    }
    @objc func tapTraining() {
        if(clickable){
            let resultVC = storyboard?.instantiateViewController(withIdentifier: "resultVC")as! GameResultViewController
            resultVC.game_Level = 3;
            present(resultVC, animated: false, completion: nil)
        }else{
            alertShow(string: "Please stay your Phone Horizontally!")
        }
    }
    @objc func tapReturn() {
        self.dismiss(animated: false, completion: nil)
    }
    func alertShow(string:String){
        let alert = UIAlertController(title: "Warnning!", message: string, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
