//
//  ReadLaterViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/27.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift


// TODO: 共通化
final class ReadLaterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // TODO: Articlesの更新
    var articles: Results<Article> = {
        return ArticleManager.getAll()
    }()

    var postUrl: URL?
    var notificationToken: NotificationToken?
    
    private let bag = DisposeBag()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "後で読む"

        tableView.rowHeight = 72.0
        tableView.separatorInset = UIEdgeInsets.zero
        let nib: UINib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Realm更新時、reloadDataする
        notificationToken = articles.addNotificationBlock { [weak self] (change: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch change {
            case .initial:
                tableView.reloadData()
            case .update(_, deletions: _, insertions: _, modifications: _):
                tableView.reloadData()
            case .error(let error):
                // TODO: エラー処理
                fatalError("\(error)")
                break
            }
        }
    }
    
    deinit {
        notificationToken?.stop()
    }


    // MARK: - TableView Delegate

    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ArticleTableViewCell
        cell.article = articles[indexPath.row]
        cell.delegate = self
        
        return cell
    }

    /// tableViewタップ時webViewに遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        
        postUrl = URL(string: article.url)
        performSegue(withIdentifier: "toWebView", sender: nil)
    }
    
    
    // MARK: - SwipeCellDelegate
    
    func didSwipeReadLater(at indexPath: IndexPath) {
        tableView.beginUpdates()
        
//        let article = articles[indexPath.row]
        // TODO: 記事をアーカイブに移動させる

        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }


    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toWebView":
            let webView: WebViewController = segue.destination as! WebViewController
            webView.url = postUrl
            webView.hidesBottomBarWhenPushed = true
        default:
            break
        }
    }

}
