//
//
// Product: 
// Project: AITestDemo
// Package: AITestDemo
//


import UIKit
import Alamofire
import SwiftyJSON

let mainDomainURL = "https://hn.algolia.com/api/v1"
class ViewController: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet var tbViewPost: UITableView!
    @IBOutlet var vwFooter: UIView!
    @IBOutlet var aiviewer: UIActivityIndicatorView!
    
    //MARK: - Variables
    var refreshControl: UIRefreshControl?
    var arrayPost:[Hit] = []
    var pageCount: Int = 0
    var isPageCompleted: Bool! = false
    
    //MARK:- Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation title
        self.setNavigationTitle()
        
        //Add Pull to refresh
        self.addRefreshControl()
        
        //Automatic tableview cell size
        self.tbViewPost.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Call webservice
        self.refreshControl?.beginRefreshing()
        self.pageCount = 0
        self.callPostAPI()
    }
    
    //MARK:- Userdefined methods
    func setNavigationTitle()  {
        self.title = "Count of posts:\(self.arrayPost.count)"
    }
    
    // MARK:- Refresh Control Methods
    func addRefreshControl() {
        if self.refreshControl == nil
        {
            refreshControl = UIRefreshControl()
            refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh data")
            refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
            tbViewPost.addSubview(refreshControl!)
        }
    }
    
    @objc func pullToRefresh() {
        self.pageCount = 0
        self.callPostAPI()
    }
    
    //MARK:- API methods
    func callPostAPI() {
        let serviceURL = "\(mainDomainURL)/search_by_date?tags=story&page=\(self.pageCount)"
        //Network indicatior
        
        let param: [String: Any] = [:]
        ApiClient.apiRequest(urlString: serviceURL, method: .get, headers: header, parameter: param) { status, message, data in
            
            if status {
                do {
                    let result = try JSONDecoder().decode(PostDetail.self, from: data)
                    
                    if self.pageCount == 0 {
                        self.refreshControl?.endRefreshing()
                        self.arrayPost.removeAll()
                        self.setNavigationTitle()
                    }
                    let postList = result.hits
                    let totalCount = result.nbPages
                    
                    print("pagecount : \(self.pageCount) of totalCount : \(totalCount)")
                    if self.pageCount < totalCount {
                        self.isPageCompleted = false
                        for i in 0..<postList.count {
                            self.arrayPost.append(postList[i])
                        }
                        self.aiviewer.stopAnimating()
                        if (self.pageCount == totalCount - 1){
                            self.isPageCompleted = true
                        }
                    } else{
                        self.isPageCompleted = true
                    }

                    self.setNavigationTitle()
                    self.tbViewPost.reloadData()
                
                } catch {
                    self.refreshControl?.endRefreshing()
                    print(error)
                }
            } else {
                self.refreshControl?.endRefreshing()
                //Show error
            }
        }
        
    }
    
}

class ViewCell: UITableViewCell{
    static let cellIdentifier = "ViewCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tbViewPost.dequeueReusableCell(withIdentifier: ViewCell.cellIdentifier, for: indexPath) as! ViewCell
        
        let post = self.arrayPost[indexPath.row]
        
        cell.lblTitle.text = post.title
        cell.lblDate.text = post.createdAt
        
        if indexPath.row == self.arrayPost.count - 1 && !self.isPageCompleted {
            pageCount = pageCount + 1
            aiviewer.startAnimating()
            self.callPostAPI()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isPageCompleted == true || arrayPost.count == 0 {
            return UIView()
        }
        return vwFooter
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isPageCompleted == true || arrayPost.count == 0 {
            return 0.0001
        }
        return 70.0
    }
}





