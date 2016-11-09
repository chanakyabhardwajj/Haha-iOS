//
//  JokesTableController.swift
//  Haha
//
//  Created by Chanakya Bhardwaj on 08/11/2016.
//  Copyright © 2016 Chanakya Bhardwaj. All rights reserved.
//

import UIKit

class Joke {
    var title: String = ""
    var text: String = ""
    var id: String = ""
    var name: String = ""
    var urlString: String = ""
}

enum JokesCategory : String {
    case Hot = "hot", Best = "top"
}

class JokesTableController: UITableViewController, ErrorCellDelegate {
    struct TableCellIdentifiers {
        static let JokeCell: String = "JokeCell"
        static let LoadingCell: String = "LoadingCell"
        static let ErrorCell: String = "ErrorCell"
    }

    var jokes = [Joke]()
    var isFetching: Bool = false
    var hasFailed: Bool = false
    var lastJokeName: String = ""
    let jokeLimit = 25
    var jokesCategory = JokesCategory.Hot
    
    @IBAction func loadMore(_ sender: UIBarButtonItem) {
        fetchJokes(false)
        let i = NSIndexPath(row: jokes.count, section: 0)
        tableView.scrollToRow(at: i as IndexPath, at: .bottom, animated: true)
    }

    @IBAction func jokesCategoryChanged(_ sender: AnyObject) {
        if(jokesCategorySegmentedControl.selectedSegmentIndex == 0) {
            jokesCategory = JokesCategory.Hot
        } else if(jokesCategorySegmentedControl.selectedSegmentIndex == 1) {
            jokesCategory = JokesCategory.Best
        }
        fetchJokes(true)
    }
    
    @IBOutlet weak var jokesCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var jokesTable: UITableView!

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        fetchJokes(true)
    }

    func tryAgain() {
        fetchJokes(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        fetchJokes(true)
        setUpJokesTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowJoke" {
            let jokeViewController = segue.destination as! JokeViewController
            let indexPath = sender as! IndexPath
            if indexPath.row < jokes.count {
                let joke = jokes[indexPath.row]
                jokeViewController.joke = joke
            }
        }
    }
}

//Extension for all JokesTable related code
extension JokesTableController {
    func setUpJokesTable() {
        jokesTable.rowHeight = 80
        
        let jokeNib = UINib(nibName: TableCellIdentifiers.JokeCell, bundle: nil)
        jokesTable.register(jokeNib, forCellReuseIdentifier: TableCellIdentifiers.JokeCell)
        
        let loadingNib = UINib(nibName: TableCellIdentifiers.LoadingCell, bundle: nil)
        jokesTable.register(loadingNib, forCellReuseIdentifier: TableCellIdentifiers.LoadingCell)
        
        let errorNib = UINib(nibName: TableCellIdentifiers.ErrorCell, bundle: nil)
        jokesTable.register(errorNib, forCellReuseIdentifier: TableCellIdentifiers.ErrorCell)

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetching {
            return jokes.count + 1
        }
        
        if hasFailed {
            return jokes.count + 1
        }

        return jokes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if (index < jokes.count) {
            let cellIdentifier = TableCellIdentifiers.JokeCell
            var cell: JokeCell! = jokesTable.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! JokeCell
            
            if cell == nil {
                cell = JokeCell(style: .default, reuseIdentifier: cellIdentifier)
            }

            let joke = jokes[index]
            cell.jokeText!.text = joke.title
            return cell
        } else if (index == jokes.count) {
            if isFetching {
                let cellIdentifier = TableCellIdentifiers.LoadingCell
                let cell = jokesTable.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            }
            
            if hasFailed {
                let cellIdentifier = TableCellIdentifiers.ErrorCell
                let cell = jokesTable.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ErrorCell
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell is JokeCell {
            performSegue(withIdentifier: "ShowJoke", sender: indexPath)
        }        
    }
}


//Extension for all Jokes Data Model related code
extension JokesTableController {
    func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parse(dictionary: [String: Any]) -> [Joke]? {
        guard let dataDict = dictionary["data"] as? [String: Any] else {
            print("Expected a 'data' field")
            return []
        }
        
        guard let jokesItems = dataDict["children"] as? [[String: Any]] else {
            print("Expected a 'children' array")
            return []
        }
        
        var jokes = [Joke]()
        
        for item in jokesItems {
            guard let jokeItem = item["data"] as? [String: Any] else {
                print("Expected a 'data' field")
                continue
            }
            let joke = Joke()
            joke.title = jokeItem["title"] as! String
            joke.text = jokeItem["selftext"] as! String
            joke.urlString = jokeItem["url"] as! String
            joke.id = jokeItem["id"] as! String
            joke.name = jokeItem["name"] as! String
            jokes.append(joke)
        }
        
        return jokes
    }

    func buildURLForJokes() -> URL {
        let apiUrl = "https://www.reddit.com/r/jokes+DirtyJokes+MeanJokes+DadJokes+cleanjokes/\(jokesCategory.rawValue)/.json?limit=\(String(jokeLimit))&after=\(lastJokeName)"
        return URL(string: apiUrl)!
    }
    
    func fetchJokes(_ refresh: Bool) {
        if (isFetching) {
            return
        }

        hasFailed = false
        isFetching = true
        
        if (refresh) {
            jokes = []
            lastJokeName = ""
        }
        jokesTable.reloadData()


        let session = URLSession.shared
        let dataTask = session.dataTask(with: buildURLForJokes(), completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Failure! \(error)")
                self.hasFailed = true
            } else if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 {
                let parsedJSON = self.parse(json: data!)
                let parsedJokes = self.parse(dictionary: parsedJSON!)

                self.hasFailed = false
                for p in parsedJokes! {
                    if self.jokes.contains(where: { $0.name == p.name }) {
                        continue
                    } else {
                        self.jokes.append(p)
                    }
                }
                self.lastJokeName = (self.jokes.last?.name)!
            } else {
                print("Failure! \(response)")
                self.hasFailed = true
            }
            
            self.isFetching = false
            DispatchQueue.main.async {
                self.jokesTable.reloadData()
            }
        })
        dataTask.resume()
    }

}

