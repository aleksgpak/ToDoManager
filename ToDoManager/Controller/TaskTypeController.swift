//
//  TaskTypeController.swift
//  ToDoManager
//
//  Created by Aleksandr Pak
//

import UIKit

class TaskTypeController: UITableViewController {
    // тип задачи
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    // доступные типы задач и их описания
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Важная", description: "Задача с приоритетным выполнением. Все важные задачи выводятся выше задач с обычным приоритетом"),
        (type: .normal, title: "Обычная", description: "Задача с обычным приоритетом")
    ]
    
    // выбранный приоритет
    var selectedType: TaskPriority = .normal
    // обработчик-замыкание выбора типа
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // регистрация кастомной ячейки
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypesInformation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        let typeDescription = taskTypesInformation[indexPath.row]
        
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = taskTypesInformation[indexPath.row].type
        doAfterTypeSelected?(selectedType)
        navigationController?.popViewController(animated: true)
    }
}
