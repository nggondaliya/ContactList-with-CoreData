//
//  ContactDetailCell.swift
//  CoreData_Demo
//
//  Created by Nirav Gondaliya on 02/03/21.
//  Copyright © 2021 Nirav Gondaliya. All rights reserved.
//

import UIKit

class ContactDetailCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
