

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let tweetCount = 100
    
    let swifter = Swifter(consumerKey: "B2Ss3JGig53sz5iayT8ueZoT3", consumerSecret: "15aN9lpLAIjfPTRT3VECDdgLYpTk3vyTMQtTInafWRQJL8vKDF")


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return false
       }

    @IBAction func predictPressed(_ sender: Any) {
            fetchTweets()
        
    
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended) { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string  {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                        
                    }
                }
                
                self.makePrediction(with: tweets)
     
            } failure: { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            
       let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
        } catch {
            print("There was an error with making a prediction \(error)")
        }
        
    }
    
    func updateUI(with sentimentScore: Int) {
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "🥲"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "🤬"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        
    }
    
}

