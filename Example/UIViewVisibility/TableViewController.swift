//
//  TableViewController.swift
//  UIViewVisibility
//
//  Created by m-miyagi on 2016/09/15.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

import UIKit


extension String {
	static func randomAlphaNumeric(_ length: Int) -> String {
		
		let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let allowedCharsCount = UInt32(allowedChars.characters.count)
		var randomString = ""
		
		for _ in (0..<length) {
			let randomNum = Int(arc4random_uniform(allowedCharsCount))
			let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
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
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewDidLoad()
		
		view.layoutIfNeeded()
	}
	
}

extension TableViewController: UITableViewDataSource {
	// MARK: - Table view data source

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
//		if cell.frame.size.width != tableView.bounds.width {
//			cell.frame.size.width = tableView.bounds.width
//			cell.setNeedsLayout()
//			cell.layoutIfNeeded()
//		}

		let item = items[indexPath.row]
		
		// yellow view
		if item.horizontalSpace {
			cell.horizontalSpaceView.visibility = .visible
		}
		else {
			cell.horizontalSpaceView.visibility = .gone(.horizontally, to: .center)
		}
		
		// top label (red)
		cell.topLabel.text = item.topText
		
		// center label (green)
		if let centerText = item.centerText {
			cell.centerLabel.superview?.visibility = .visible
			cell.centerLabel.text = centerText
		}
		else {
			cell.centerLabel.superview?.visibility = .gone(.vertically, to: .center)
		}

		// bottom label (blue)
		if let bottomText = item.bottomText {
			cell.bottomLabel.superview?.visibility = .visible
			cell.bottomLabel.text = bottomText
		}
		else {
			cell.bottomLabel.superview?.visibility = .gone(.vertically, to: .center)
		}
		
		cell.updateConstraintsIfNeeded()
		
		cell.setNeedsLayout()
		cell.layoutIfNeeded()
		
		return cell
	}
}

extension TableViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
}
