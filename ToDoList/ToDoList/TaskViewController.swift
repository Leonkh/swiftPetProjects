//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 23.11.2020.
//
import CoreData
import LocalAuthentication
import UIKit

class TaskViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var taskTextView: UITextView!
    @IBOutlet var taskNameTextView: UITextView!
    @IBOutlet var taskNameLabel: UILabel!
    
    var task: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task {
            taskNameTextView.text = task.value(forKeyPath: "nameOfTask") as! String
            taskTextView.text = task.value(forKeyPath: "descriptionTask") as! String
        }
        taskNameTextView.delegate = self
        taskNameTextView.tag = 0
        taskTextView.delegate = self
        taskTextView.tag = 1
        
        taskNameLabel.layer.borderColor = UIColor.lightGray.cgColor
        taskTextView.layer.borderColor = UIColor.lightGray.cgColor
        taskNameTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        taskNameLabel.layer.borderWidth = 3
        taskTextView.layer.borderWidth = 3
        taskNameTextView.layer.borderWidth = 3
        
        taskNameLabel.layer.cornerRadius = 5
        taskTextView.layer.cornerRadius = 5
        taskNameTextView.layer.cornerRadius = 5
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil) // ремонт клавиатуры
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil) // ремонт клавиатуры
        
        notificationCenter.addObserver(self, selector: #selector(hideAll), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(openAll), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let deleteButtom = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain, target: self, action: #selector(deleteTask))
        toolbarItems = [deleteButtom]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch textView.tag {
        case 0:
            task?.setValue(textView.text, forKeyPath: "nameOfTask")
        default:
            task?.setValue(textView.text, forKeyPath: "descriptionTask")
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            taskTextView.contentInset = .zero
        } else {
            taskTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        taskTextView.scrollIndicatorInsets = taskTextView.contentInset
        
        let selectedRange = taskTextView.selectedRange
        taskTextView.scrollRangeToVisible(selectedRange)
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
    
    
    @objc func deleteTask() {
        let ac = UIAlertController(title: "Do you want delete this task?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {
            [weak self] _ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext =
                appDelegate.persistentContainer.viewContext
            managedContext.delete((self?.task)!)
            do {
                try  managedContext.save()
                self?.navigationController?.popViewController(animated: true)
                self?.dismiss(animated: true)
            } catch {
                print("Cant save delete change")
            }
        })
        let no = UIAlertAction(title: "No", style: .cancel)
        ac.addAction(no)
        ac.addAction(yes)
        present(ac, animated: true)
    }
    
}
