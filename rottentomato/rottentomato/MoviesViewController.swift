//
//  MoviesViewController.swift
//  rottentomato
//
//  Created by Kris Aldenderfer on 5/10/15.
//  Copyright (c) 2015 Shopular. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorIconImageView: UIImageView!
    
    var movies: [NSDictionary]?
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(self.refreshControl, atIndex: 0)
    
        queryRottenTomatoes()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryRottenTomatoes() {
        SVProgressHUD.show()
        
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
        let req = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let resp = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            
            if let resp = resp {
                self.movies = resp["movies"] as? [NSDictionary]
                self.tableView.reloadData()
                
                SVProgressHUD.dismiss()
            } else {
                self.showErrorView()
            }
        })
    }
    
    func onRefresh() {
        queryRottenTomatoes()
        self.refreshControl.endRefreshing()
    }
    
    func showErrorView() {
        self.errorImageView.hidden = false
        self.errorLabel.hidden = false
        self.errorIconImageView.hidden = false
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
            self.errorImageView.hidden = true
            self.errorLabel.hidden = true
            self.errorIconImageView.hidden = true
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterImageView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
