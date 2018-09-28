//
//  LocationDetailsVC.swift
//  MyLocations
//
//  Created by Marton Zeisler on 2018. 09. 28..
//  Copyright © 2018. marton. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsVC: UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark{
            addressLabel.text = string(from: placemark)
        }else{
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: Date())
    }
    
    func string(from placemark: CLPlacemark) ->String{
        var line1 = ""
        
        if let s = placemark.subThoroughfare{ // house number
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare{ // street name
            line1 += s + " "
        }
        
        var line2 = ""
        if let s = placemark.locality{ // city
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea{ // state or province
            line2 += s + " "
        }
        
        if let s = placemark.postalCode{ // post code
            line2 += s
        }
        
        return line1 + "\n" + line2
    }

    func format(date: Date) ->String{
        return dateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        }else if indexPath.section == 2 && indexPath.row == 2{
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        }else{
            return 44
        }
    }

}
