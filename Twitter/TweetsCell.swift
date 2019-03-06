//
//  TweetsCell.swift
//  Twitter
//
//  Created by Kunal Agarwal on 04/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//

import UIKit

class TweetsCell: UITableViewCell {

    @IBOutlet weak var favorLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favorButton: UIButton!
    
    var tweetID = Int()
    var favorited = false
    var retweeted = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onRetweet(_ sender: Any) {
        if(!retweeted)
        {
            TwitterAPICaller.client?.reTweet(tweetID: tweetID, success: {
                self.setRetweeted(true)
            }, failure: { (Error) in
                print("error \(Error)")
            })
        }
        else
        {}
    }
    @IBAction func onFavor(_ sender: Any) {
        if(!favorited)
        {
            TwitterAPICaller.client?.favorTweet(tweetID: tweetID, success: {
                self.setFavorited(true)
            }, failure: { (Error) in
                print("error \(Error)")
            })
        }
        else
        {
            TwitterAPICaller.client?.unfavorTweet(tweetID: tweetID, success: {
                self.setFavorited(false)
            }, failure: { (Error) in
                print("error \(Error)")
            })
        }
    }
    
    func setFavorited(_ isFavorited:Bool){
        favorited = isFavorited
    if(isFavorited)
    {
        favorButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
    }
    else{
        favorButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
        }
}
    func setRetweeted(_ isRetweeted:Bool){
        retweeted = isRetweeted
        if(isRetweeted)
        {
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
            retweetButton.isEnabled = false
        }
        else{
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
            retweetButton.isEnabled = true
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
