//
//  ViewController.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 22.11.2020.
//
<<<<<<< HEAD
import CoreData
=======

>>>>>>> 0d539447d70eb35da603b44864bb954ff9b0ce79
import UIKit

class ViewController: UIViewController {

<<<<<<< HEAD
    @IBOutlet var tableView: UITableView!
    
    var tasks: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ToDoList"
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellTask")
    }
    
    

    @IBAction func addTask(_ sender: Any) {
        
    }
    
    func save(nameOfTask: String, task: String, status: Bool = false) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext) else {return}
        
        let task = NSManagedObject(entity: entity, insertInto: managedContext)
        
        task.setValue(nameOfTask, forKeyPath: "nameOfTask")
        task.setValue(task, forKeyPath: "task")
        task.setValue(status, forKeyPath: "status")
        
        do {
            try managedContext.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTask", for: indexPath)
        let task = tasks[indexPath.row]
        if let statusTask = task.value(forKeyPath: "status") as? Bool {
            switch statusTask {
            case true:
                
            default:
                //
            }
        }
        
        return cell
    }
    
    
    
}
=======
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

>>>>>>> 0d539447d70eb35da603b44864bb954ff9b0ce79
