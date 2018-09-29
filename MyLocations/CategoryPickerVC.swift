//
//  CategoryPickerVC.swift
//  MyLocations
//
//  Created by Marton Zeisler on 2018. 09. 29..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit

class CategoryPickerVC: UITableViewController {
    
    var selectedCategoryName = ""
    
    let categories = ["No Category", "Apple Stpre", "Bar", "Club", "Grocery Store", "Historic Buildin", "House", "Icecream Vendor", "Landmark", "Park"]
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if categories.contains(selectedCategoryName){
            selectedIndexPath = IndexPath(row: categories.firstIndex(of: selectedCategoryName)!, section: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        if categories[indexPath.row] == selectedCategoryName{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCell = selectedIndexPath else {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            selectedIndexPath = indexPath
            return
        }
        
        
        if indexPath.row != selectedCell.row{
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
            
            let oldCell = tableView.cellForRow(at: selectedCell)
            oldCell?.accessoryType = .none
            
            selectedIndexPath = indexPath
        }else{
            let cell = tableView.cellForRow(at: selectedCell)
            cell?.accessoryType = .none
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory"{
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                selectedCategoryName = categories[indexPath.row]
            }
            
            
        }
    }



}
