//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Brubrusha on 11/29/20.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    var currentTasks: Results<Task>!
    var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showTasks", for: indexPath)
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content

        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlertTask()
    }

}

extension TasksViewController {
    
    private func showAlertTask() {
        let alert = AlertController(title: "New Task", message: "Insert new Task", preferredStyle: .alert)
        
        alert.action { newValue, note in
            let task = Task(value: [newValue, note])
            
            StorageManager.shard.save(task: task, in: self.taskList)
            let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
            self.tableView.insertRows(at: [rowIndex], with: .automatic)
        }
        
        present(alert, animated: true)
    }
}
