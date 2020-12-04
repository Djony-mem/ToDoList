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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.shard.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (_, _, isDone) in
            self.showAlertTask(task: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let title = indexPath.section == 0 ? "Done" : "Undone"
        let doneAction = UIContextualAction(style: .normal, title: title) {
            (_, _, isDone) in
            StorageManager.shard.done(task: task)
            
            let indexPathCurrentList = IndexPath(row: self.currentTasks.count - 1, section: 0)
            let indexPathCompletionList = IndexPath(row: self.completedTasks.count - 1, section: 1)
            
            let indexPathDestination = indexPath.section == 0 ? indexPathCompletionList : indexPathCurrentList
            
            tableView.moveRow(at: indexPath, to: indexPathDestination)
            isDone(true)
        }
        doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, deleteAction, editAction])
    }
    
    @objc private func addButtonPressed() {
        showAlertTask()
    }

}

extension TasksViewController {
    
    private func showAlertTask(task: Task? = nil, complition: (() -> Void)? = nil) {
        
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = AlertController(title: title, message: "Insert new Task", preferredStyle: .alert)
        
        alert.action(task: task) { newValue, note in
            if let task = task, let complition = complition {
                StorageManager.shard.edit(task: task, name: newValue, note: note)
                complition()
            } else {
                let task = Task(value: [newValue, note])
                StorageManager.shard.save(task: task, in: self.taskList)
                let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
}
