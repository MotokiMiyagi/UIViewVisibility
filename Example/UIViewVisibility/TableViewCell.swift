//
//  TableViewCell.swift
//  UIViewVisibility
//
//  Created by m-miyagi on 2016/09/15.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

	@IBOutlet weak var horizontalSpaceView: UIView!
	
	@IBOutlet weak var topLabel: UILabel!
	
	@IBOutlet weak var centerLabel: UILabel!
	
	@IBOutlet weak var bottomLabel: UILabel!
	
	override func layoutSubviews() {		
		super.layoutSubviews()
		topLabel.preferredMaxLayoutWidth = topLabel.bounds.width
		centerLabel.preferredMaxLayoutWidth = centerLabel.bounds.width
		bottomLabel.preferredMaxLayoutWidth = bottomLabel.bounds.width
	}
}
