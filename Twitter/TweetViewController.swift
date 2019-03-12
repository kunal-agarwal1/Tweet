//
//  TweetViewController.swift
//  Twitter
//
//  Created by Kunal Agarwal on 05/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    let characterLimit = 140

    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        charCountLabel.text = "\(characterLimit)";
        // Do any additional setup after loading the view.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Construct what the new text would be if we allowed the user's latest edit
        
        var newText = textView.text.count + text.count
        if(text.count == 0 && newText != 0){
        newText = newText - 1;
        }
        print(textView.text + "q\(text.count)")
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
