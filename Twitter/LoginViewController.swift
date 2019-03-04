//
//  LoginViewController.swift
//  Twitter
//
//  Created by Kunal Agarwal on 04/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
loginButton.layer.cornerRadius = loginButton.frame.height * 0.5
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if(UserDefaults.standard.bool(forKey: "isLoggedIn"))
{ self.performSegue(withIdentifier: "LogInToHome", sender: self)
        }
        
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let url = "https://api.twitter.com/oauth/request_token"
        TwitterAPICaller.client?.login(url: url, success: {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "isLoggedIn")
            self.performSegue(withIdentifier: "LogInToHome", sender: self)
        }, failure: { (Error) in
            
            let alert = UIAlertController(title: "Could not Log In", message: "Something caused the login to fail. Try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            print("Could Not Log in")
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
