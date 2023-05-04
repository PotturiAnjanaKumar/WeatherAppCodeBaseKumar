//
//  LocationDescriptionCell.swift
//  WeatherApp
//
//  Created by ANJANA KUMAR on 04/05/23.
//

import UIKit
import MapKit

class LocationDescriptionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }
    
    func updateCell(mapItem: MKMapItem) {
        textLabel?.text = mapItem.name
    }

}
