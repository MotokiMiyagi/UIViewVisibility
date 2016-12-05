//
//  ViewController.swift
//  UIViewVisibility
//
//  Created by m-miyagi on 09/15/2016.
//  Copyright (c) 2016 m-miyagi. All rights reserved.
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
	
	fileprivate var accessingViews: [UIView] {
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
	
	fileprivate var selectedView: UIView? = nil
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		updateSegmentedControl()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
	
		selectedView = touches.first?.view
		updateSegmentedControl()
	}
}


// MARK: IBAction
extension ViewController {
	
	@IBAction func refreshAction(_ sender: AnyObject) {
		
		selectedView = nil
		updateSegmentedControl()

		accessingViews.forEach { (view: UIView) in
			view.visibility = .visible
		}
	}
	
	@IBAction func valueChangedAction(_ sender: AnyObject) {
		updateVisibility()
	}
}


// MARK: Private Method
private extension ViewController {

	func updateSegmentedControl() {
		guard let view = selectedView else {
			segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
			return
		}

		switch view.visibility {
		case .visible:
			segmentedControl.selectedSegmentIndex = 0

		case .invisible:
			segmentedControl.selectedSegmentIndex = 1

		case .gone(let direction, to: _):
			switch direction {
			case .horizontally:
				segmentedControl.selectedSegmentIndex = 2
				
			case .vertically:
				segmentedControl.selectedSegmentIndex = 3
			}
		}
	}

	func updateVisibility() {
		guard let view = selectedView else {
			return
		}
		
		switch segmentedControl.selectedSegmentIndex {
		case 0:
			view.visibility = .visible
			
		case 1:
			view.visibility = .invisible
			
		case 2:
			view.visibility = .gone(.horizontally, to: .center)
			view.visibility = .gone(.horizontally, to: .center)
			
		case 3:
			view.visibility = .gone(.vertically, to: .center)
			
		default:
			break
		}
		
		UIView.animate(withDuration: 0.25, animations: { [unowned weakSelf = self] in
			weakSelf.view.layoutIfNeeded()
		}) 
	}
}


extension ViewController: UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return UIView.Visibility.enums.count
//		return 3
	}
}

extension ViewController: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return UIView.Visibility.enums[row].stringValue()
//		return ""
	}
}



