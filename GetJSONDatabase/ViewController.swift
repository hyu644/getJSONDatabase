//
//  ViewController.swift
//  GetJSONDatabase
//
//  Created by hyu on R 2/09/02.
//  Copyright © Reiwa 2 hyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var okashiList:[(name: String, maker: String, url: URL, image: URL)] = []
    
    struct ItemJSON: Codable {
        let name: String?
        let maker: String?
        let url: URL?
        let image: URL?
    }
    
    struct ResultJSON: Codable{
        let item:[ItemJSON]?
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.searchBar.delegate = self
        searchBar.placeholder = "ここにテキストを書く"
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchKeyword = searchBar.text{
            print(searchKeyword)
            searchOkashi(keyword: searchKeyword)
        }
    }
    
    func searchOkashi(keyword: String){
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
                return
        }
    
     guard let req_url = URL(string: "http://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=d")
      
       else{
        return
 }
        print(req_url)
        
        let req = URLRequest(url: req_url)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            
            session.finishTasksAndInvalidate()
            
            do{
                let decoder = JSONDecoder()
                let JSON = try decoder.decode(ResultJSON.self, from:data!)
                //print(JSON)
                
                if let items = JSON.item{
                    self.okashiList.removeAll()
                    
                    for item in items {
                        if let name = item.name,
                            let maker = item.maker,
                            let url = item.url,
                            let image = item.image{
                            //タプル型（変数を一つにまとめる）
                            let okashi = (name,maker,url,image)
                            //取り出したJSONデータを配列に
                            self.okashiList.append(okashi)
                            print(self.okashiList)
                        }
                    }
                }
                
                self.tableview.reloadData()
                
            }catch{
                print("エラー")
            }
        })
        
        task.resume()
        }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return okashiList.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        
        cell.textLabel?.text = okashiList[indexPath.row].name
        
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            cell.imageView?.image = UIImage(data:imageData)
        }
        //cell.imageView?.image = okashiList[IndexPath.row].image
        
        return cell
        
        
        
     }
}
