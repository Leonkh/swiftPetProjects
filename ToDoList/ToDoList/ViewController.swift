//
//  ViewController.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 23.11.2020.
//
import CoreData
import UIKit

//protocol CustomCellDelegate: class {
//    func customCell(_ cell: TaskCell, didPressButton: UIButton)
//}

class ViewController: UITableViewController {
    
    var tasks: [NSManagedObject] = [] // создаем массив наших тасков
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDoList" // заглавие
        
        // Загружаем данные с Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        // Данные с Core Data загружены в массив tasks
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTask)) // кнопка в Navigation Bar для добавления тасков
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count // количество ячеек равно количеству тасков
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell // инициализируем нашу кастомную ячейку
        //        cell.delegate = self
        //        print("Ячейка создана")
        cell.nameOfTaskLabel.text = tasks[indexPath.row].value(forKeyPath: "nameOfTask") as! String // присваевыем текст в nameOfTasklabel равный сохраненному имени
        cell.taskTextLabel.text = tasks[indexPath.row].value(forKeyPath: "descriptionTask") as! String // присваевыем текст в taskTextlabel равный сохраненному описанию таска
        cell.nameOfTaskLabel.sizeToFit()
        cell.taskTextLabel.sizeToFit()
        let status = tasks[indexPath.row].value(forKeyPath: "statusTask") as! Bool // считываем статус таска
        cell.statusTask.layer.cornerRadius = 5 // закругление краев кнопки
        cell.statusTask.layer.borderWidth = 3.0 // толщина краев кнопки
        cell.statusTask.layer.borderColor = UIColor.lightGray.cgColor // цвет краев кнопки
        if status {
            if let galochka = UIImage(named: "checkmark") {// если выполнен таск показать галочку
//            cell.statusTask.imageView?.image = galochka
                cell.statusTask.setImage(galochka, for: .normal)
            print("Галочка поставилась")
            }
        } else {
            cell.statusTask.setImage(nil, for: .normal)
        }
        cell.statusTask.tag = indexPath.row
        if let butt = cell.statusTask as? UIButton {
            let intt = indexPath.row
            butt.addTarget(self, action: #selector(changeStatus(sender:)), for: .touchUpInside)
        }
        //            cell.statusTask.backgroundColor = .white
        //        }
        
        return cell
    }
    
    @objc func addNewTask() {
        let ac = UIAlertController(title: "Create new task", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Input name of task"
        }
        ac.addTextField { (textField) in
            textField.placeholder = "Input text of task"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {
            [weak self] _ in
            guard let nameTask = ac.textFields?.first?.text else {return}
            guard let descriptionTask = ac.textFields?[1].text else {return}
            self?.save(nameOfTask: nameTask, textOfTask: descriptionTask)
            self?.tableView.reloadData()
        })
        ac.addAction(ok)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func save(nameOfTask: String, textOfTask: String) { // функция сохранения таска в Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else {return}
        
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        
        task.setValue(nameOfTask, forKeyPath: "nameOfTask")
        task.setValue(textOfTask, forKeyPath: "descriptionTask")
        task.setValue(false, forKeyPath: "statusTask")
        
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @objc func changeStatus(sender: UIButton) {
        
        //        sender.backgroundColor = .red
        print(sender.tag)
        let numb = sender.tag
        let lastStatus = tasks[numb].value(forKeyPath: "statusTask") as! Bool
        print("Статус перед измением: \(lastStatus)")
        tasks[numb].setValue(!lastStatus, forKeyPath: "statusTask")
        print("Статус после измения: \(tasks[numb].value(forKeyPath: "statusTask") as! Bool)")
        tableView.reloadData()
    }
    
    
}

//extension ViewController: CustomCellDelegate {
//    // You get notified by the cell instance and the button when it was pressed
//    func customCell(_ cell: TaskCell, didPressButton: UIButton) {
//        // Get the indexPath
////        didPressButton.backgroundColor = .red
//        if let indexPathRow = tableView.indexPath(for: cell)?.row {
//        let lastStatus = tasks[indexPathRow].value(forKeyPath: "statusTask") as! Bool
//        tasks[indexPathRow].setValue(!lastStatus, forKeyPath: "statusTask")
//        tableView.reloadData()
//        } else {
//            print("Нажатие кнопки зафиксировано, но индекс не прошел")
//        }
//    }
//}

