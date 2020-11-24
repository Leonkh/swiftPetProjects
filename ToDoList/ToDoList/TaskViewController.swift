//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 23.11.2020.
//
import CoreData
import UIKit

class TaskViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var taskTextView: UITextView!
    @IBOutlet var taskNameTextView: UITextView!
    @IBOutlet var taskNameLabel: UILabel!
    
    var task: NSObject?
    
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil) // ремонт клавиатуры
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil) // ремонт клавиатуры
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
    
}
