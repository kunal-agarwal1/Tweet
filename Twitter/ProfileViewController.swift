//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Kunal Agarwal on 11/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    @objc func loadData()
    {
        let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        let parameters = ["skip_status" : true]
        TwitterAPICaller.client?.getAccount(url: url, parameters: parameters, success: { (profileInfo: NSDictionary) in
            print(profileInfo)
            self.nameLabel.text = profileInfo["name"] as? String
            self.tagLabel.text = "@" + (profileInfo["screen_name"] as! String)
            self.followersLabel.text = "\(profileInfo["followers_count"] as! Int)"
            self.followingLabel.text = "\(profileInfo["friends_count"] as! Int)"
            self.tweetsLabel.text = "\(profileInfo["statuses_count"] as! Int)"
            
            let imageUrl = URL(string: (profileInfo["profile_image_url_https"] as! String))
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data {
                self.profileImage.image = UIImage(data: imageData)
                self.profileImage.layer.cornerRadius =  self.profileImage.frame.height * 0.5
                self.profileImage.clipsToBounds = true
                
            }

            if let maybe = profileInfo["profile_background_image_url_https"] as? String{
            let imageUrl2 = URL(string: (maybe))
            let data2 = try? Data(contentsOf: imageUrl2!)
            
            if let imageData2 = data2 {
                self.bgImage.image = UIImage(data: imageData2)
                self.bgImage.clipsToBounds = true
                
                }}
            else{
                self.bgImage.backgroundColor = UIColor(hexString: ("#" + (profileInfo["profile_background_color"] as! String)))
            }

        }, failure: { (Error) in
            let alert = UIAlertController(title: "Could not retrieve Tweets", message: "Something caused the connection to fail. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            print("could not retrieve tweets")
        })
    }
    

    @IBAction func cancel(_ sender: Any) {
           dismiss(animated: true, completion: nil)
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
extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff) >> 8) / 255
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
