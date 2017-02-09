//
//  PaginationVC.swift
//  Firebase-iOS-Pagination
//
//  Created by BURAK GÜNDÜZ on 09/02/2017.
//  Copyright © 2017 Burak Gunduz. All rights reserved.
//

import UIKit
import Firebase

class PaginationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pageOnTimestamp: String!
    var posts = [Post]()
    
    var postCounter = 0
    var loadingStatus = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.initFirstLoading { (granted) in
            
            if granted == true {
                
                self.loadingStatus = false
                self.tableView.reloadData()
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell") as! PaginationVC
        
        // You can configure on your own cell class.
        cell.configure(postIn: self.posts[indexPath.row])
        
        return cell
    }
    
    func initFirstLoading(_ completion: @escaping (Bool) -> ()) {
        
        self.loadingStatus = true
        
        let num = "-\(Timestamp)"
        let pageOn: Double = (num as NSString).doubleValue
        
        let query = DataService.ds.REF_POSTS.queryOrdered(byChild: "reverseTimestamp")
            .queryStarting(atValue: pageOn, childKey: "reverseTimestamp")
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.postCounter = Int(snapshot.childrenCount)
            
            if snapshot.value is NSNull {
                
                print("There is no post.")
                
                if let alert = showErrorAlert("There is no post.", msg: "Try again later or add one.") {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                
                query.queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    self.posts.removeAll(keepingCapacity: true)
                    
                    for (i, snap) in snapshot.children.enumerated() {
                        
                        if let postAllDict = snapshot.value as? [String: AnyObject] {
                            if let postDict = postAllDict[(snap as AnyObject).key as String] as? [String: AnyObject] {
                                
                                print("Displaying \(i) post")
                                print(postDict)
                                
                                let post = Post(key: (snap as AnyObject).key as String, postDict: postDict)
                                self.posts.append(post)
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        completion(true)
                    })
                    
                })
            }
        })
    }
    
    func reloadFeed() {
        
        print("Feed will be refreshed here later.")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        print("index cell \(indexPath.row)")
        
        if self.posts.count == indexPath.row + 1 && !self.loadingStatus && self.posts.count < self.postCounter {
            
            self.loadingStatus = true
            
            print("\(self.posts.count) \(self.postCounter)  ***")
            
            print("called load")
            
            self.loadMoreCompletion({ (granted) in
                
                if granted == true {
                    
                    
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (Timer) in
                        
                        tableView.reloadData()
                        self.loadingStatus = false
                        
                    })
                    
                }
            })
        }
    }
    
    func loadMoreCompletion(_ completion: @escaping (Bool) -> ()) {
        
        self.loadingStatus = true
        
        if self.posts.count < self.postCounter {
            
            if let lastTimestamp = self.posts.last?.reverseTimestamp {
                
                print("Last post's timestamp handled here: \(lastTimestamp)")
                
                let arr = "\(lastTimestamp)".components(separatedBy: ".")
                let arr2 = Int(arr[1])!
                let last = "\(Int(arr[0])! + 1).\(arr2)"
                let checkLast = (last as NSString).doubleValue
                
                let query = DataService.ds.REF_POSTS.queryOrdered(byChild: "reverseTimestamp")
                                                    .queryStarting(atValue: checkLast, childKey: "reverseTimestamp")
                
                query.queryLimited(toFirst: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    for (i, snap) in snapshot.children.enumerated() {
                        
                        print("in for loop")
                        
                        if let postAllDict = snapshot.value as? [String: AnyObject] {
                            if let postDict = postAllDict[(snap as AnyObject).key as String] as? [String: AnyObject] {
                                
                                print("Displaying from load more \(i) post")
                                print(postDict)
                                
                                let post = Post(key: (snap as AnyObject).key as String, postDict: postDict)
                                self.posts.append(post)
                            }
                            
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        completion(true)
                    })
                })
            }
        }
        
    }
    
    @IBAction func addBtn_clicked(_ sender: Any) {
        
        let addTVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTVC") as! AddTVC
        self.navigationController?.pushViewController(addTVC, animated: true)
    }
    
}
