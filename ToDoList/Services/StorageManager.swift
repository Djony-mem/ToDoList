//
//  StoragManager.swift
//  ToDoList
//
//  Created by Brubrusha on 12/1/20.
//

import RealmSwift

class StorageManager {
    static let shard = StorageManager()
    
    let realm = try! Realm()
    
    private init() {}
    
    func save(taskList: TaskList) {
        write {            
            realm.add(taskList)
        }
    }
    func delete(taskList: TaskList) {
        write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(taskList: TaskList?, newValue: String) {
        write {
            taskList?.name = newValue
        }
    }
    
    func done(taskList: TaskList) {
        write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func save(task: Task, in taskList: TaskList) {
        write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func edit(task: Task, name: String, note: String) {
        write {
            task.name = name
            task.note = note
        }
    }
    
    func done(task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
    
    private func write(_ complete: () -> Void) {
        do{
            try realm.write {
                complete()
            }
        } catch let error {
            print(error)
        }
    }
    
    
}
