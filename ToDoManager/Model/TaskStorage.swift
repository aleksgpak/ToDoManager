//
//  TaskStorage.swift
//  ToDoManager
//
//  Created by Aleksandr Pak
//

import UIKit
// протокол сущности "Хранилище задач"
protocol TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol]) -> Void
}

// сущность "Хранилище задач"
class TasksStorage: TaskStorageProtocol {
    
    private var storage = UserDefaults.standard
    // Ключ, по которому будет происходить сохранение хранилища
    var storageKey: String = "tasks"
    
    // Перечисление с ключами для записи в User Defaults
    private enum TaskKey: String {
        case title
        case type
        case status
    }
    // загрузка задач
    func loadTasks() -> [TaskProtocol] {
        var resultTasks: [TaskProtocol] = []
        let tasksFromStorage = storage.array(forKey: storageKey) as? [[String: String]] ?? []
        for task in tasksFromStorage {
            guard let title = task[TaskKey.title.rawValue],
                  let typeRaw = task[TaskKey.type.rawValue],
                  let statusRaw = task[TaskKey.status.rawValue] else {
                continue
            }
            let type: TaskPriority = typeRaw == "important" ? .important : .normal
            let status: TaskStatus = statusRaw == "current" ? .current : .completed
            resultTasks.append(Task(title: title, type: type, status: status))
        }
        return resultTasks
    }
    // сохранение задач
    func saveTasks(_ tasks: [TaskProtocol]) {
        var arrayForStorage: [[String: String]] = []
        tasks.forEach { task in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[TaskKey.title.rawValue] = task.title
            newElementForStorage[TaskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
            newElementForStorage[TaskKey.status.rawValue] = (task.status == .current) ? "current" : "completed"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
