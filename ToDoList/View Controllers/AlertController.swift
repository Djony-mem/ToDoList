//
//  AlertController.swift
//  ToDoList
//
//  Created by Brubrusha on 12/2/20.
//

import UIKit

class AlertController: UIAlertController {
    
    var barButton = "Save"
    
    func action(with taskList: TaskList?, complition: @escaping (String) -> Void) {
        
        if taskList != nil {
            barButton = "Update"
        }
        let saveAction = UIAlertAction(title: barButton, style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            complition(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.placeholder = "List Name"
            textField.text = taskList?.name
        }
    }
    
    func action(_ complition: @escaping (String, String) -> Void) {
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newTask = self.textFields?.first?.text else { return }
            guard !newTask.isEmpty else { return }
           
            if let note = self.textFields?.last?.text {
                complition(newTask, note)
            } else {
                complition(newTask, "")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        
        addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        addTextField { textField in
            textField.placeholder = "Nots"
        }
    }
}
