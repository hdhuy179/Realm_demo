//
//  BookTableViewCell.swift
//  Realm_demo
//
//  Created by Hoang Dinh Huy on 9/30/19.
//  Copyright © 2019 Hoang Dinh Huy. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    private var onToggleCompleted: ((BookItem) -> Void)?
    private var book: BookItem?
    
    func configureWith(_ book: BookItem, onToggleCompleted: ((BookItem) -> Void)? = nil) {
        self.book = book
        self.onToggleCompleted = onToggleCompleted
        self.textLabel?.text = book.name
        self.accessoryType = book.isCompleted ? .checkmark : .none
    }
    
    func toggleCompleted() {
        guard let book = book else { fatalError("Book not found") }
        
        onToggleCompleted?(book)
    }
}
