//
//  TaskListsViewController.swift
//  ToDoList
//
//  Created by Brubrusha on 11/29/20.
//

import UIKit
import RealmSwift

class TaskListsViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = StorageManager.shard.realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellForTask", for: indexPath)
        let taskList = taskLists[indexPath.row]
        cell.configur(taskList: taskList)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.shard.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (_, _, isDone) in
            self.showAlert(taskList: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") {
            (_, _, isDone) in
            StorageManager.shard.done(taskList: taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.taskList = taskList
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showAlert()
    }
    
    @IBAction func sortedTaskList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "name")
            : taskLists.sorted(byKeyPath: "date")
        
        tableView.reloadData()
    }
    
}

extension TaskListsViewController {
    private func showAlert(taskList: TaskList? = nil, complition: (() -> Void)? = nil) {
        
        let title = taskList != nil ? "Edit TaskList" : "New TaskList"
        
        let alert = AlertController(title: title, message: "Insert new List", preferredStyle: .alert)
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let complition = complition {
                StorageManager.shard.edit(taskList: taskList, newValue: newValue)
                complition()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                
                StorageManager.shard.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
            
        }
        
        present(alert, animated: true)
    }
}
