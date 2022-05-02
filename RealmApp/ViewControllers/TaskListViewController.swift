
import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func  addButtonPressed(_ sender: Any) {
        showALert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        taskLists = sender.selectedSegmentIndex == 0
            ? taskLists.sorted(byKeyPath: "name", ascending: true)
            : taskLists.sorted(byKeyPath: "date", ascending: false)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (_, _, _) in
            StorageManager.shared.delete(taskList: taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showALert(taskList: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        var uncompletedTasks: [Task] = []
        
        for task in taskList.tasks {
            if !task.isComplete {
                uncompletedTasks.append(task)
            }
        }
        
        let title = uncompletedTasks.count > 0 ? "Done" : "Undone"
        
        let doneAction = UIContextualAction(style: .normal, title: title) { (_, _, isDone) in
            if uncompletedTasks.count > 0 {
                StorageManager.shared.done(taskList: taskList)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            } else {
                StorageManager.shared.unDone(taskList: taskList)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
        }
        
        editAction.backgroundColor = .orange
        
        if uncompletedTasks.count > 0 {
            doneAction.backgroundColor = .green
        } else {
            doneAction.backgroundColor = .gray
        }
        
        if taskList.tasks.count == 0 {
            return UISwipeActionsConfiguration(actions: [ editAction, deleteAction])
        } else {
            return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let controller = segue.destination as! TasksViewController
        controller.taskList = taskLists[indexPath.row]
    }

}

extension TaskListViewController {
    
    private func showALert(taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        
        let alert = AlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        alert.action(with: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, newValue: newValue)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
    
}
