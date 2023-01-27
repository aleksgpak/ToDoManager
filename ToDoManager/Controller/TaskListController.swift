//
//  TaskListController.swift
//  ToDoManager
//
//  Created by Aleksandr Pak
//

import UIKit

class TaskListController: UITableViewController {

    // хранилище задач
    var tasksStorage: TaskStorageProtocol = TasksStorage()
    // коллекция задач
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (priority, taskList) in tasks {
                tasks[priority] = taskList.sorted { task1, task2 in
                    let t1Position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let t2Position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return t1Position < t2Position
                }
            }
            
            var savingArray: [TaskProtocol] = []
            tasks.forEach{ _, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
//    порядок отображения задач по приоритету
    let sectionsTypesPosition: [TaskPriority] = [.important, .normal]
//    порядок отображения задач по статусу
    var tasksStatusPosition: [TaskStatus] = [.current, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return tasks.count
        return sectionsTypesPosition.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let tasksType = sectionsTypesPosition[section]
        if tasksType == .normal {
            return "Текущие"
        } else if tasksType == .important {
            return "Важные"
        }
        return ""
    }
    
    private func getConfiguredTaskCell(for indexPath: IndexPath) -> UITableViewCell {
        // прототип ячейки
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        if currentTask.status == .current {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String {
        if status == .current {
            return "\u{25CB}"
        } else if status == .completed {
            return "\u{25C9}"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        
        guard tasks[taskType]![indexPath.row].status == .current else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tasks[taskType]![indexPath.row].status = .completed
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        let actionSwipe = UIContextualAction(style: .normal, title: "Не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .current
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        let actionSwipeEdit = UIContextualAction(style: .normal, title: "Изменить") { _,_,_ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        
        actionSwipeEdit.backgroundColor = .darkGray
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipe, actionSwipeEdit])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeEdit])
        }
        
        return actionsConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
    func setTasks(_ taskCollection: [TaskProtocol]) {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        taskCollection.forEach{ task in
            tasks[task.type]?.append(task)
        }
    }
}
