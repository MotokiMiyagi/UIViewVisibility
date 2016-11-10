//
//  TableViewController.swift
//  UIViewVisibility
//
//  Created by m-miyagi on 2016/09/15.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit


extension String {
	static func randomAlphaNumeric(length: Int) -> String {
		
		let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let allowedCharsCount = UInt32(allowedChars.characters.count)
		var randomString = ""
		
		for _ in (0..<length) {
			let randomNum = Int(arc4random_uniform(allowedCharsCount))
			let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
			randomString += String(newCharacter)
		}
		
		return randomString
	}
}

class TableViewController: UIViewController {

	struct Item {
		var horizontalSpace: Bool = false
		var topText: String? = nil
		var centerText: String? = nil
		var bottomText: String? = nil
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	var items = [Item]()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		for index in 0..<(arc4random() % 50 + 1) {

			// horizontal space
			let horizontalSpace = arc4random() % 2 == 0
			
			// top text
			let topText = "index: \(index)"
			
			// center text
			var centerText: String? = nil
			let centerTextLength = Int(arc4random() % 200 + 1)
			if centerTextLength % 5 != 0 {
				centerText = String.randomAlphaNumeric(centerTextLength)
			}

			// bottom text
			var bottomText: String? = nil
			let bottomTextLength = Int(arc4random() % 200 + 1)
			if bottomTextLength % 5 != 0 {
				bottomText = String.randomAlphaNumeric(bottomTextLength)
			}

			let item = Item(
				horizontalSpace: horizontalSpace,
				topText: topText,
				centerText: centerText,
				bottomText: bottomText
			)
			items.append(item)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.min))
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewDidLoad()
		
		view.layoutIfNeeded()
	}
	
}

extension TableViewController: UITableViewDataSource {
	// MARK: - Table view data source

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath) as! TableViewCell
//		if cell.frame.size.width != tableView.bounds.width {
//			cell.frame.size.width = tableView.bounds.width
//			cell.setNeedsLayout()
//			cell.layoutIfNeeded()
//		}

		let item = items[indexPath.row]
		
		// yellow view
		if item.horizontalSpace {
			cell.horizontalSpaceView.visibility = .Visible
		}
		else {
			cell.horizontalSpaceView.visibility = .Gone(.Horizontally, to: .Center)
		}
		
		// top label (red)
		cell.topLabel.text = item.topText
		
		// center label (green)
		if let centerText = item.centerText {
			cell.centerLabel.superview?.visibility = .Visible
			cell.centerLabel.text = centerText
		}
		else {
			cell.centerLabel.superview?.visibility = .Gone(.Vertically, to: .Center)
		}

		// bottom label (blue)
		if let bottomText = item.bottomText {
			cell.bottomLabel.superview?.visibility = .Visible
			cell.bottomLabel.text = bottomText
		}
		else {
			cell.bottomLabel.superview?.visibility = .Gone(.Vertically, to: .Center)
		}
		
		cell.updateConstraintsIfNeeded()
		
		cell.setNeedsLayout()
		cell.layoutIfNeeded()
		
		return cell
	}
}

extension TableViewController: UITableViewDelegate {
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
