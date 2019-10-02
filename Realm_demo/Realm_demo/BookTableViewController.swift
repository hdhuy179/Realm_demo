//
//  BookTableViewController.swift
//  Realm_demo
//
//  Created by Hoang Dinh Huy on 9/30/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import RealmSwift

class BookTableViewController: UITableViewController {

    private var books: Results<BookItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        books = BookItem.getAll()
        
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: "BookTableViewCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookTableViewCell", for: indexPath) as? BookTableViewCell,
            let book = books?[indexPath.row] else {
                return BookTableViewCell(frame: .zero)
        }
        // 2
        cell.configureWith(book) { [weak self] book in
            book.toggleCompleted()
//            self?.tableView.reloadData()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookTableViewCell else { return }
        cell.toggleCompleted()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let book = books?[indexPath.row],
            editingStyle == .delete else { return }
        book.delete()
//        self.tableView.reloadData()
    }
    
    @IBAction func onAddButtonClicked(_ sender: Any) {
        showInputBookAlert("Add book name") { name in
            _ = BookItem.add(name: name)
//            self.tableView.reloadData()
        }
    }
    
    func showInputBookAlert(_ title: String, isSecure: Bool = false, text: String? = nil, callback: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { field in
            field.isSecureTextEntry = isSecure
            field.text = text
        })
        
        alert.addAction(UIAlertAction(title: "Oke", style: .default) { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else {
                self.showInputBookAlert(title, callback: callback)
                return
            }
            callback(text)
        })
        
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.present(alert, animated: true, completion: nil)
    }
    
    private var token: NotificationToken?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        token = books?._observe({ [weak tableView] changes in
            guard let tableView = tableView else { return }
            switch changes {
            case .initial://
                tableView.reloadData()
            case .update(_, let deletions , let insertions, let updates):
                tableView.applyChanges(deletions: deletions, insertions: insertions, updates: updates)
            case .error: break
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        token?.invalidate()
    }
}

extension UITableView {
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
        beginUpdates()
        deleteRows(at: deletions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        insertRows(at: insertions.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        reloadRows(at: updates.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        endUpdates()
    }
}
