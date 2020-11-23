//
//  Cell.swift
//  ToDoList
//
//  Created by Леонид Хабибуллин on 22.11.2020.
//

import Foundation
import UIKit

class CellTask: UITableViewCell {
    

    @IBOutlet var status: UISwitch!
    @IBOutlet var taskView: UITextField!
    @IBOutlet var nameOfTaskView: UITextField!
}
