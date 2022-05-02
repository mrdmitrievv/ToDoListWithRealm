
import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    var currentTask: Results<Task>!
    var completedTask: Results<Task>!
    
    lazy var sampleView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        currentTask = taskList.tasks.filter("isComplete = false")
        completedTask = taskList.tasks.filter("isComplete = true")
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
        section == 0 ? currentTask.count : completedTask.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Current Tasks" : "Completed Task"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)

        let task = indexPath.section == 0 ? currentTask[indexPath.row] : completedTask[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? currentTask[indexPath.row] : completedTask[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, _) in
            StorageManager.shared.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let title = indexPath.section == 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: title) { (_, _, isDone) in
            StorageManager.shared.done(task: task)
            
            let indexPathForCurrentTask = IndexPath(row: self.currentTask.count - 1, section: 0)
            let indexPathForComletedTask = IndexPath(row: self.completedTask.count - 1, section: 1)
            
            let destinationIndexRow = indexPath.section == 0 ? indexPathForComletedTask : indexPathForCurrentTask
            
            tableView.moveRow(at: indexPath, to: destinationIndexRow)
            isDone(true)
            
        }
        
        editAction.backgroundColor = .orange
        if !task.isComplete {
            doneAction.backgroundColor = .green
        } else {
            doneAction.backgroundColor = .gray
        }
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    @objc
    private func addButtonPressed() {
        showAlert()
    }

}

extension TasksViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit task" : "New Task"
        
        let alert = AlertController(title: title, message: "What do you want to do?", preferredStyle: .alert)
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, name: newValue, note: note)
                completion()
            } else {
            let task = Task(value: [newValue, note])
                StorageManager.shared.save(task: task, in: self.taskList)
                let rowIndex = IndexPath(row: self.currentTask.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
}
