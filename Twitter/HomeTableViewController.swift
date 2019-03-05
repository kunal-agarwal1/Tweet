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
    var numberOfTweets = Int()
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfTweets = 20
        loadTweets()
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
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
        print(timeStr)
   
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
        print(cell.timeLabel.text!)

        cell.retweetLabel.text = "\(tweetArray[indexPath.row]["retweet_count"] as! Int)"
        cell.favorLabel.text = "\(tweetArray[indexPath.row]["favorite_count"] as?Int ?? 0)"
        
        return cell;
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
