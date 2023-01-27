//
//  TaskEditController.swift
//  ToDoManager
//
//  Created by Aleksandr Pak
//

import UIKit

class TaskEditController: UITableViewController {

    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .current
        doAfterEdit?(title, type, status)
        navigationController?.popViewController(animated: true)
    }
    
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .current
    
    private var taskTitles: [TaskPriority: String] = [
        .normal: "Обычная",
        .important: "Важная"
    ]
    
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle?.text = taskText
        taskTypeLabel?.text = taskTitles[taskType]
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            let destination = segue.destination as! TaskTypeController
            destination.selectedType = taskType
            destination.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
                taskTypeLabel?.text = taskTitles[taskType]
            }
        }
    }
}
