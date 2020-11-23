//
//  TaskCell.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 23.11.2020.
//

import UIKit

class TaskCell: UITableViewCell {
    
//    weak var delegate: CustomCellDelegate?
    
    @IBOutlet var statusTask: UIButton!
    @IBOutlet var nameOfTaskLabel: UILabel!
    @IBOutlet var taskTextLabel: UILabel!
    
    @IBAction func taskStatusTapped(_ sender: UIButton) {
//        self.delegate?.customCell(self, didPressButton: sender)
        print("Нажатие кнопки зафиксировано")
    }
    
}
