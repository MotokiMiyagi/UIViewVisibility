//
//  ViewController.swift
//  UIViewVisibility
//
//  Created by Motoki Miyagi on 09/15/2016.
//  Copyright (c) 2016 Motoki Miyagi. All rights reserved.
//

import UIKit
import UIViewVisibility


class ViewController: UIViewController {

	// MARK: IBOutlet
	
	@IBOutlet weak var segmentedControl: UISegmentedControl!
	
	@IBOutlet weak var topView: UIView!
	
	@IBOutlet weak var contentView: UIView!

	@IBOutlet weak var topViewLabel: UILabel!
	
	@IBOutlet weak var centerView: UIView!
	
	@IBOutlet weak var centerViewLabel1: UILabel!
	
	@IBOutlet weak var centerViewLabel2: UILabel!
	
	@IBOutlet weak var bottomView: UIView!
	
	@IBOutlet weak var bottomViewLabel1: UILabel!
	
	@IBOutlet weak var bottomViewLabel2: UILabel!
	
	@IBOutlet weak var bottomViewLabel3: UILabel!
	
	
	// MARK: Private Properties
	
	private var accessingViews: [UIView] {
		return [
			topView,
			contentView,
			topViewLabel,
			centerView,
			centerViewLabel1,
			centerViewLabel2,
			bottomView,
			bottomViewLabel1,
			bottomViewLabel2,
			bottomViewLabel3,
		]
	}
	
	private var selectedView: UIView? = nil
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event)
	
		selectedView = touches.first?.view
		updateSegmentedControl()
	}
}


// MARK: IBAction
extension ViewController {
	
	@IBAction func refreshAction(sender: AnyObject) {
		
		selectedView = nil
		updateSegmentedControl()

		accessingViews.forEach { (view: UIView) in
			view.visibility = .Visible
		}
	}
	
	@IBAction func valueChangedAction(sender: UISegmentedControl) {
		guard let view = selectedView else {
			return
		}

		switch sender.selectedSegmentIndex {
		case 0:
			view.visibility = .Visible

		case 1:
			view.visibility = .Invisible

		case 2:
			view.visibility = .Gone(.Horizontally)

		case 3:
			view.visibility = .Gone(.Vertically)
		
		default:
			break
		}
	}
}


// MARK: Private Method
private extension ViewController {

	func updateSegmentedControl() {
		guard let view = selectedView else {
			segmentedControl.selected = false
			return
		}

		switch view.visibility {
		case .Visible:
			segmentedControl.selectedSegmentIndex = 0

		case .Invisible:
			segmentedControl.selectedSegmentIndex = 1

		case .Gone(let direction):
			switch direction {
			case .Horizontally:
				segmentedControl.selectedSegmentIndex = 2
				
			case .Vertically:
				segmentedControl.selectedSegmentIndex = 3
			}
		}
	}
}