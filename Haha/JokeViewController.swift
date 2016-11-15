//
//  JokeViewController.swift
//  Haha
//
//  Created by Chanakya Bhardwaj on 08/11/2016.
//  Copyright © 2016 Chanakya Bhardwaj. All rights reserved.
//

import UIKit

class JokeViewController: UIViewController {
    var joke: Joke?
    
    @IBAction func blockJoke(_ sender: UIButton) {
        let alert = UIAlertController(title: "Block this content?", message: "This joke will be removed and never shown again to you.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Block", style: UIAlertActionStyle.default, handler: goBack))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var jokeView: UITextView!
    
    @IBAction func shareJoke(_ sender: UIBarButtonItem) {
        if let j = joke {
            let textToShare = j.title + j.text
            let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            present(activityVC, animated: true, completion: nil)
        }
    }

    func goBack(action: UIAlertAction) -> Void {
        print("go back")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jokeView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7

        let textAttributes: [String : Any] = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular),
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        let titleAttribute = [ NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: UIFontWeightSemibold) ]

        if let j = joke {
            let jokeTitle = NSMutableAttributedString(string: j.title, attributes: titleAttribute)
            jokeTitle.append(NSAttributedString(string:"\n\n\n"))
            
            let jokeText = NSMutableAttributedString(string: j.text, attributes: textAttributes)
            jokeTitle.append(jokeText)
            
            jokeView!.attributedText = jokeTitle
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.jokeView.setContentOffset(CGPoint.zero, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
