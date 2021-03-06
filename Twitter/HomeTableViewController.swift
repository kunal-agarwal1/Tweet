//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Kunal Agarwal on 04/03/19.
//  Copyright © 2019 Dan. All rights reserved.
//


import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var heightArray = [Int]()
    var numberOfTweets = Int()
    let myRefreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfTweets = 20
        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }

    @objc func loadTweets()
    {
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = 20
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: ["count" : numberOfTweets], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()

        }, failure: { (Error) in
            let alert = UIAlertController(title: "Could not retrieve Tweets", message: "Something caused the connection to fail. Please try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            self.myRefreshControl.endRefreshing()

            print("could not retrieve tweets")
        })
    }
    
    func loadMoreTweets(){
        let url = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 10
        if numberOfTweets > 200
        {
            let alert = UIAlertController(title: "Maximum number of tweets reached!", message: "Twitter only allows up to 200 tweets to be loaded at once.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return;
        }
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: ["count" : numberOfTweets], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("could not retrieve more tweets")
        })

    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == (tweetArray.count - 1)){
            loadMoreTweets()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetsCell", for: indexPath) as! TweetsCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        let imageUrl = URL(string: (user["profile_image_url_https"] as! String))
        let data = try? Data(contentsOf: imageUrl!)
        cell.mediaNo = 0
        cell.extraHeight = 0
        if let imageData = data {
            cell.profileImage.image = UIImage(data: imageData)
            cell.profileImage.layer.cornerRadius =  cell.profileImage.frame.height * 0.5
            cell.profileImage.clipsToBounds = true

        }
        if (indexPath.row % 2 == 1)
        {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
        cell.nameLabel.text = (user["name"] as! String)
        
        let tweetext = (tweetArray[indexPath.row]["text"] as! String)
        if let index = tweetext.range(of: "http", options: .backwards)?.lowerBound
        {
            cell.tweetLabel.text = String(tweetext[tweetext.startIndex..<index])
        }
        else{
        cell.tweetLabel.text = tweetext
        }
        
        cell.userIdLabel.text = "@" + (user["screen_name"] as! String)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        let timeStr = (tweetArray[indexPath.row]["created_at"] as! String)
   
        let postdate = dateFormatter.date(from:timeStr)!
            let now = Date()
        let diffInDays = Calendar.current.dateComponents([.day], from: postdate , to: now).day!
        cell.timeLabel.text = "\(diffInDays)d"
        if diffInDays == 0{
            let diffInHours = Calendar.current.dateComponents([.hour], from: postdate , to: now).hour!
            cell.timeLabel.text = "\(diffInHours)h"
        if diffInHours == 0{
            let diffInMins = Calendar.current.dateComponents([.minute], from: postdate , to: now).minute!
            cell.timeLabel.text = "\(diffInMins)m"
            if diffInMins == 0{
                let diffInSecs = Calendar.current.dateComponents([.second], from: postdate , to: now).second!
                cell.timeLabel.text = "\(diffInSecs)s"
                 }
            }
        }
        
        cell.tweetID = tweetArray[indexPath.row]["id"] as! Int
        
        cell.setFavorited(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)

        cell.retweetLabel.text = "\(tweetArray[indexPath.row]["retweet_count"] as! Int)"
        cell.favorLabel.text = "\(tweetArray[indexPath.row]["favorite_count"] as?Int ?? 0)"
        if let entity  = tweetArray[indexPath.row]["extended_entities"] as? NSDictionary{
        if let media = entity["media"] as? [NSDictionary]{
            let frame = tableView.rectForRow(at: indexPath)
            print(frame.size.height)
            cell.mediaNo = media.count
            print(media)
             if(heightArray.count <= indexPath.row){
            heightArray.insert(150, at: indexPath.row);
            }
            for medi in media
            {
        let mediaUrl = URL(string: medi["media_url_https"] as! String)
            let size = medi["sizes"] as! NSDictionary
            let thumb = size["medium"] as! NSDictionary
            var h =  thumb["h"] as! Int
            var w =  thumb["w"] as! Int
                let screenWid = Int(UIScreen.main.bounds.width/2)
                h = Int((CGFloat(h)/CGFloat(w)) * CGFloat(screenWid))
                w = screenWid

            cell.extraHeight = cell.extraHeight + h

            let data = try? Data(contentsOf: mediaUrl!)
 
            if let imageData = data {
                cell.mediaImage.image = UIImage(data: imageData)
                cell.mediaImage.clipsToBounds = true
                cell.mediaImage.frame = CGRect(x: screenWid-w/2, y: 1, width: w, height: h)
            }
        }
            heightArray[indexPath.row] = 150 + cell.extraHeight
            }
        
    }
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(heightArray.count <= indexPath.row){
            heightArray.insert(150, at: indexPath.row);
            
        }
        return CGFloat(heightArray[indexPath.row]);//Choose your custom row height
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are you sure you want to Log Out?", message: "You will have to log back in to continue using the app.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            TwitterAPICaller.client?.logout()
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "isLoggedIn")
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)



    }
    
   

}
/**
 LINKS TO GIF/MP4 STORY
 
 https://media.giphy.com/media/1zlTTztFtzfNJR9Hdq/giphy.gif
 
 https://gph.is/g/aX8zYOa
 
 https://streamable.com/s/ui2vn/fppxci
 
 https://giphy.com/gifs/1zlTTztFtzfNJR9Hdq/fullscreen
 */
