//
//  ViewController.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 23.11.2020.
//
import CoreData
import LocalAuthentication
import UIKit

private var tasks: [NSManagedObject] = [] // создаем массив наших тасков

class ViewController: UITableViewController {
    
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(hideAll), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(openAll), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        completedTaskBottom()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count // количество ячеек равно количеству тасков
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell // инициализируем нашу кастомную ячейку
        cell.nameOfTaskLabel.text = tasks[indexPath.row].value(forKeyPath: "nameOfTask") as! String // присваевыем текст в nameOfTasklabel равный сохраненному имени
        cell.taskTextLabel.text = tasks[indexPath.row].value(forKeyPath: "descriptionTask") as! String // присваевыем текст в taskTextlabel равный сохраненному описанию таска
        cell.nameOfTaskLabel.sizeToFit()
//        cell.taskTextLabel.size
        
        let status = tasks[indexPath.row].value(forKeyPath: "statusTask") as! Bool // считываем статус таска
        cell.statusTask.layer.cornerRadius = 5 // закругление краев кнопки
        cell.statusTask.layer.borderWidth = 3.0 // толщина краев кнопки
        cell.statusTask.layer.borderColor = UIColor.lightGray.cgColor // цвет краев кнопки
        if status {
            if let galochka = UIImage(named: "checkmark") {// если выполнен таск показать галочку
                cell.statusTask.setImage(galochka, for: .normal)
            }
        } else { // если таск не выполнен то пустое поле
            cell.statusTask.setImage(nil, for: .normal)
        }
        cell.statusTask.tag = indexPath.row // таг кнопки равен номеру ячейки
        if let butt = cell.statusTask {
            butt.addTarget(self, action: #selector(changeStatus(sender:)), for: .touchUpInside) // меняем статус таска при нажатии
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tvc = storyboard?.instantiateViewController(withIdentifier: "TaskViewController") as? TaskViewController else {return}
        tvc.task = tasks[indexPath.row] // передаем task
        navigationController?.pushViewController(tvc, animated: true) // переходим в tvc
    }
    
    @objc func addNewTask() { // функция создания таска
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
        
        print(sender.tag)
        let numb = sender.tag
        let lastStatus = tasks[numb].value(forKeyPath: "statusTask") as! Bool
        print(lastStatus)
        tasks[numb].setValue(!lastStatus, forKeyPath: "statusTask")
        print(tasks[numb].value(forKeyPath: "statusTask") as! Bool)
        saveChages()
        completedTaskBottom()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
        completedTaskBottom()
    }
    
    @objc func hideAll() {
        guard view.isHidden == false else {return}
        view.isHidden = true
        title = "You must pass authentication"
    }
    
    @objc func openAll() {
        guard view.isHidden == true else {return}
        let contex = LAContext() // объект LA. Error в LA это часть Obj-C, а не Swift
        var error: NSError?
        
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success, authencticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.view.isHidden = false
                        self?.title = ""
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You cann't be verified. Please, try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
            
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
//    func taskComplete(indexTask: Int) {
//        let completedTask = tasks[indexTask]
//        tasks.remove(at: indexTask)
//        tasks.append(completedTask)
//        saveChages()
//        tableView.reloadData()
//    }
    
    func completedTaskBottom() {
        for task in tasks {
            if task.value(forKeyPath: "statusTask") as! Bool == true {
                let swapTask = task
                guard let index = tasks.firstIndex(of: task) else {return }
                tasks.remove(at: index)
                tasks.append(swapTask)
            }
        }
        
        tableView.reloadData()
    }
    
    func saveChages() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        do {
            try  managedContext.save()
            print("Данные сохранены")
        } catch {
            print("Cant save delete change")
    }
}
}


