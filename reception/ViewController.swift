//
//  ViewController.swift
//  reception
//
//  Created by Sachiko Miyamoto on 2016/10/05.
//  Copyright © 2016年 宮本幸子. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pushhere: UIImageView!
    @IBOutlet weak var wait: UIImageView!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fadeOutTimer()

        wait.isHidden = true
        wait.alpha = 1
        pushhere.isHidden = false
        pushhere.alpha = 1

        pushhere.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        animation.repeatCount = MAXFLOAT
        animation.duration = 0.8
        pushhere.layer.add(animation, forKey: "opacity")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushButton(_ sender: AnyObject) {
        if timer.isValid == true {
            timer.invalidate()
        }
        wait.fadeOut(type: FadeType.Normal)
        pushhere.fadeOut(type: FadeType.Normal)
        
        // create the url-request
        let urlString = "https://api.instapush.im/v1/post"
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        
        // set the method(HTTP-POST)
        request.httpMethod = "POST"
        // set the header(s)
        request.addValue("57f2fc98a4c48a2a482077c4", forHTTPHeaderField: "x-instapush-appid")
        request.addValue("dd543bc65b4e0973264823e678d5915f", forHTTPHeaderField: "x-instapush-appsecret")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set the request-body(JSON)
        let params = [
            "event": "coming",
            "trackers": [
                "name":"お客様"
            ]
        ] as [String : Any]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let erro as NSError {
            print(erro.localizedDescription)
        }
        
        // use NSURLSessionDataTask
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, e in
            if (e == nil) {
                DispatchQueue.main.async {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                        // print(json)
                        if json["error"] as? Error == nil {
                            print("success")
                            self.wait.fadeIn(type: FadeType.Normal)
                            self.fadeOutTimer()
                        }
                    } catch let err as NSError {
                        print(err.localizedDescription)
                    }
                }
            } else {
                print(e?.localizedDescription)
            }
        })
        task.resume()
    }
    
    func waitfadeOut() {
        self.wait.fadeOut(type: FadeType.Slow)
    }
    
    func fadeOutTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 9.0, target: self, selector: #selector(ViewController.waitfadeOut), userInfo: nil, repeats: false)
    }

}

enum FadeType: TimeInterval {
    case
    Normal = 0.2,
    Slow = 1.0
}

extension UIView {
    func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeIn(duration: type.rawValue, completed: completed)
    }
    
    /** For typical purpose, use "public func fadeIn(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeIn(duration: TimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: duration,
                                   animations: {
                                    self.alpha = 1
        }) { finished in
            completed?()
        }
    }
    func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil) {
        fadeOut(duration: type.rawValue, completed: completed)
    }
    /** For typical purpose, use "public func fadeOut(type: FadeType = .Normal, completed: (() -> ())? = nil)" instead of this */
    func fadeOut(duration: TimeInterval = FadeType.Slow.rawValue, completed: (() -> ())? = nil) {
        UIView.animate(withDuration: duration
            , animations: {
                self.alpha = 0
        }) { [weak self] finished in
            self?.isHidden = true
            self?.alpha = 1
            completed?()
        }
    }
}

