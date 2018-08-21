//
//  ToastHelper.swift
//  WhiteGloveWorker
//
//  Created by Admin on 6/4/18.
//  Copyright © 2018 zhao'com. All rights reserved.
//

import UIKit

class ToastHelper: NSObject {
    static func showToast(view: UIView ,message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 125, y: view.frame.size.height-100, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black//.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
