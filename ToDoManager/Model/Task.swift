//
//  Task.swift
//  ToDoManager
//
//  Created by Aleksandr Pak
//

import UIKit

// приоритет задачи
enum TaskPriority {
    case normal
    case important
}

// статус задачи
enum TaskStatus {
    case current
    case completed
}
// протокол сущности "Задача"
protocol TaskProtocol {
    var title: String { get set }
    var type: TaskPriority { get set }
    var status: TaskStatus { get set }
}
// сущность "Задача"
struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}
