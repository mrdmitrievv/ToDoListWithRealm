
import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTask = taskList.tasks.filter("isComplete = false")
        let comletedTask = taskList.tasks.filter("isComplete = true")
        var content = defaultContentConfiguration()
        
        content.text = taskList.name
        
        if !currentTask.isEmpty {
            content.secondaryText = "\(currentTask.count)"
            accessoryType = .none
        } else if !comletedTask.isEmpty {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
            content.secondaryText = "0"
        }
        
        contentConfiguration = content
    }

}
