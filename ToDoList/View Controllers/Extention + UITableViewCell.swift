//
//  Extention + UITableViewCell.swift
//  ToDoList
//
//  Created by Brubrusha on 12/4/20.
//

import UIKit

extension UITableViewCell {
    func configur(taskList: TaskList) {
        let currentList = taskList.tasks.filter("isComplete = false")
        let completedList = taskList.tasks.filter("isComplete = true")
        
        var content = defaultContentConfiguration()
        
        content.text = taskList.name
        
        if !currentList.isEmpty {
            content.secondaryText = "\(currentList.count)"
            accessoryType = .none
        } else if !completedList.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            accessoryType = .none
            content.secondaryText = "0"
        }
        
        contentConfiguration = content
    }
}
