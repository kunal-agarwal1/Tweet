//
//  TweetViewController.swift
//  Twitter
//
//  Created by Kunal Agarwal on 05/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    let characterLimit = 140

    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        charCountLabel.text = "\(characterLimit)";
        
        tweetTextView.layer.cornerRadius = 8;
        tweetTextView.layer.borderColor = UIColor.gray.cgColor
        tweetTextView.layer.borderWidth = 1;
        loadData()
        // Do any additional setup after loading the view.
    }
    @objc func loadData()
    {
        let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
        let parameters = ["skip_status" : true]
        TwitterAPICaller.client?.getAccount(url: url, parameters: parameters, success: { (profileInfo: NSDictionary) in
                  let imageUrl = URL(string: (profileInfo["profile_image_url_https"] as! String))
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data {
                self.profileImage.image = UIImage(data: imageData)
                self.profileImage.layer.cornerRadius =  self.profileImage.frame.height * 0.5
                self.profileImage.clipsToBounds = true
                
            }
        }, failure: { (Error) in
            self.profileImage.image = (UIImage(named: "profile-icon"))
            print("could not retrieve profile image")
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Construct what the new text would be if we allowed the user's latest edit
        
        var newText = textView.text.count + text.count
        if(text.count == 0 && newText != 0){
        newText = newText - 1;
        }
        charCountLabel.text = "\(characterLimit - newText)";
        // The new text should be allowed? True/False
        return newText < characterLimit
    }

    @IBAction func tweet(_ sender: Any) {
        if(!tweetTextView.text.isEmpty)
        {
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text
                , success: {
                   self.dismiss(animated: true, completion: nil)
            }, failure: { (Error) in
                let alert = UIAlertController(title: "Could not post Tweet", message: "Something caused the connection to fail. Please try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                print("error posting tweet\(Error)")
                self.dismiss(animated: true, completion: nil)
            })
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
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
