//
//  GameResultViewController.swift
//  AlcoTestDroid
//
//  Created by Admin on 7/28/18.
//  Copyright © 2018 AlcoTestDroid. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class GameResultViewController: UIViewController, TGCameraDelegate {
    
    private var rainLayer: CAEmitterLayer!
    private var gravityLayer: CAEmitterLayer!
    
    let defaults = UserDefaults.standard
    
    public var game_Level:Int = 1;
    var game_result:String = "aa";
    var distance:String = "";
    var score:String = "";
    var state:String = "";
    var level:String = "";
    
    let showEffect:Bool = false;
    
    var ref: DatabaseReference!
    //    ref = Database.database().reference();
    var locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var m_btnAgain: UIView!
    @IBOutlet weak var m_btnReturn: UIView!
    @IBOutlet weak var m_ivWin: UIImageView!
    @IBOutlet weak var m_ivLoose: UIImageView!
    @IBOutlet weak var lb_again: UILabel!
    @IBOutlet weak var lb_return: UILabel!
    @IBOutlet weak var ScoreView: UILabel!
    
    //TGCamera Callback
    func getString(_ strResult: String!) {
        state = strResult;
        NSLog(state);
        title = "Emitter"
        
        DispatchQueue.main.async{
            self.m_btnAgain.isHidden = false
            self.m_btnReturn.isHidden = false
            self.lb_again.isHidden = false
            self.lb_return.isHidden = false
            self.ScoreView.isHidden = false;
            
            if(self.state == "Success"){
                self.setupGravityLayer()
                if self.gravityLayer.birthRate == 0 {
                    self.gravityLayer.beginTime = CACurrentMediaTime()
                    self.gravityLayer.birthRate = 1
                } else {
                    self.gravityLayer.birthRate = 0
                }
                self.m_ivWin.isHidden = false;
            }else if(self.state == "Loose"){
                self.ScoreView.isHidden = true;
                self.setupRainLayer()
                let birthRateAnimation = CABasicAnimation(keyPath: "birthRate")
                birthRateAnimation.duration = 3
                if self.rainLayer.birthRate == 0 {
                    birthRateAnimation.fromValue = 0
                    birthRateAnimation.toValue = 1
                    self.rainLayer.birthRate = 1
                } else {
                    birthRateAnimation.fromValue = 1
                    birthRateAnimation.toValue = 0
                    self.rainLayer.birthRate = 0
                }
                
                self.rainLayer.add(birthRateAnimation, forKey: "birthRate")
                DispatchQueue.main.asyncAfter(deadline: .now() + birthRateAnimation.duration) { [weak self] in
                    guard self != nil else { return }
                }
                self.m_ivLoose.isHidden = false;
            }
        }
        
        
    }

    
    private func getDistance(_ intDistance: String!) {
        distance = intDistance;
    }
    internal func getScore(_ strScore: String!) {
        score = strScore;
        DispatchQueue.main.async{
            self.m_btnAgain.isHidden = false
            self.m_btnReturn.isHidden = false
            self.lb_again.isHidden = false
            self.lb_return.isHidden = false
            self.ScoreView.isHidden = false;
            
            self.ScoreView.text = "Your Score:" + self.score + "Sec";
            let name = UserDefaults.standard.string(forKey: "name")
            var type = ""
            let uid = UserDefaults.standard.string(forKey: "uid")
            
            print(self.game_Level)
            print(name)
            
            if(self.game_Level == 1) {
                type = "Simple"
            }else if(self.game_Level == 2) {
                type = "Advance"
            }
            
            if(self.state == "Success") {
                self.ref = Database.database().reference()
                self.ref.child("Players/gameType").childByAutoId().setValue(type)
                self.ref.child("Players/name").childByAutoId().setValue(name)
                self.ref.child("Players/time").childByAutoId().setValue(self.score)
            }
        }
    }
    
    func getParam(_ param: String!) {
        level = param;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScoreView.isHidden = true;
        
        ScoreView.text = "";
        self.m_ivWin.isHidden = true;
        self.m_ivLoose.isHidden = true;
//        print(game_Level)
//        print("---------------" + game_State)
//        print(distance)
//        print(game_result)
        
        self.addBorderLine(view: m_btnAgain)
        self.addBorderLine(view: m_btnReturn)
        
        self.addViewCornor(view: m_btnAgain)
        self.addViewCornor(view: m_btnReturn)
        
        let recogReturn = UITapGestureRecognizer(target: self, action:#selector(self.TapReturn))
        m_btnReturn.isUserInteractionEnabled = true
        m_btnReturn.addGestureRecognizer(recogReturn)
        
        let recogAgain = UITapGestureRecognizer(target: self, action: #selector(TapAgain))
        m_btnAgain.isUserInteractionEnabled = true
        m_btnAgain.addGestureRecognizer(recogAgain)
    }
    
    override func viewDidAppear(_ animated: Bool) { }
    
    override func viewDidLayoutSubviews() {
        
//        m_btnAgain.isHidden = true
//        m_btnReturn.isHidden = true
//        lb_again.isHidden = true
//        lb_return.isHidden = true
        if(game_Level == 1){
            let cameraVC = TGCameraViewController(nibName: "TGCameraViewController", bundle: nil)
            cameraVC.game_level = 1;
            cameraVC.delegate = self
            present(cameraVC, animated: false, completion: nil)
        }
        if(game_Level == 2){
            let cameraVC = TGCameraViewController(nibName: "TGCameraViewController", bundle: nil)
            cameraVC.game_level = 2;
            cameraVC.delegate = self
            present(cameraVC, animated: false, completion: nil)
        }
        if(game_Level == 3){
            let cameraVC = TGCameraViewController(nibName: "TGCameraViewController", bundle: nil)
            cameraVC.game_level = 3;
            cameraVC.delegate = self
            present(cameraVC, animated: false, completion: nil)
        }
        game_Level = 0;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupRainLayer() {
        if (state == "Loose") {
            rainLayer = CAEmitterLayer()
            rainLayer.emitterShape = kCAEmitterLayerLine // Default emit orientation is up
            rainLayer.emitterMode = kCAEmitterLayerOutline
            rainLayer.renderMode = kCAEmitterLayerOldestFirst
            rainLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: 0)
            rainLayer.emitterSize = CGSize(width: view.bounds.width, height: 0)
            rainLayer.birthRate = 0 // Stop animation by default
            
            let cell = CAEmitterCell()
            cell.contents = #imageLiteral(resourceName: "rain.png").cgImage
            cell.scale = 0.05
            cell.lifetime = 5
            cell.birthRate = 300
            cell.velocity = 300
            cell.emissionLongitude = CGFloat.pi
            
            rainLayer.emitterCells = [cell]
            view.layer.addSublayer(rainLayer)
        }
    }
    
    private func setupGravityLayer() {
        if (state == "Success"){
            gravityLayer = CAEmitterLayer()
            gravityLayer.renderMode = kCAEmitterLayerOldestFirst
            gravityLayer.emitterPosition = CGPoint(x: 0, y: view.bounds.maxY)
            gravityLayer.birthRate = 0
            
            let cell = CAEmitterCell()
            cell.contents = #imageLiteral(resourceName: "Heart_red").cgImage
            cell.scale = 0.6
            cell.lifetime = 10
            cell.alphaSpeed = -0.1
            cell.birthRate = 10
            cell.velocity = 100
            cell.yAcceleration = 20
            cell.emissionLongitude = -CGFloat.pi / 4
            cell.emissionRange = CGFloat.pi / 4
            cell.spin = 0 // default value
            cell.spinRange = CGFloat.pi * 2
            
            let cell2 = CAEmitterCell()
            cell2.contents = #imageLiteral(resourceName: "Heart_blue").cgImage
            cell2.scale = 0.4
            cell2.lifetime = 20
            cell2.alphaSpeed = -0.05
            cell2.birthRate = 5
            cell2.velocity = 135
            cell2.yAcceleration = 20
            cell2.emissionLongitude = -CGFloat.pi / 4
            cell2.emissionRange = CGFloat.pi / 4
            cell2.spin = 0 // default value
            cell2.spinRange = CGFloat.pi * 2
            
            gravityLayer.emitterCells = [cell, cell2]
            view.layer.addSublayer(gravityLayer)
        }
        
    }
    
   
    @objc func TapReturn(){
        self.dismiss(animated: false, completion: nil)
    }
    @objc func TapAgain(){
        let cameraVC = TGCameraViewController(nibName: "TGCameraViewController", bundle: nil)
        if(level == "simple"){
            cameraVC.game_level = 1;
        }else if(level == "advance"){
            cameraVC.game_level = 2
        }else if(level == "training"){
            cameraVC.game_level = 3
        }
        print( cameraVC.game_level);
        m_ivWin.isHidden = true;
        m_ivLoose.isHidden = true;
        cameraVC.delegate = self;
        present(cameraVC, animated: false, completion: nil)
    
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
