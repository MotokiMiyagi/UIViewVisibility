//
//  UIViewVisibility.swift
//  Pods
//
//  Created by m-miyagi on 2016/09/15.
//
//

import UIKit


// MARK: - Operator Overload
/**
Equatable UIView.Stick
*/
public func ==(lhs: UIView.Stick, rhs: UIView.Stick) -> Bool {
	switch lhs {
	case .left:
		switch rhs {
		case .left:
			return true
		case .right:
			return false
		case .top:
			return false
		case .bottom:
			return false
		case .center:
			return false
		case .none:
			return false
		}
	case .right:
		switch rhs {
		case .left:
			return false
		case .right:
			return true
		case .top:
			return false
		case .bottom:
			return false
		case .center:
			return false
		case .none:
			return false
		}
	case .top:
		switch rhs {
		case .left:
			return false
		case .right:
			return false
		case .top:
			return true
		case .bottom:
			return false
		case .center:
			return false
		case .none:
			return false
		}
	case .bottom:
		switch rhs {
		case .left:
			return false
		case .right:
			return false
		case .top:
			return false
		case .bottom:
			return true
		case .center:
			return false
		case .none:
			return false
		}
	case .center:
		switch rhs {
		case .left:
			return false
		case .right:
			return false
		case .top:
			return false
		case .bottom:
			return false
		case .center:
			return true
		case .none:
			return false
		}
	case .none:
		switch rhs {
		case .left:
			return false
		case .right:
			return false
		case .top:
			return false
		case .bottom:
			return false
		case .center:
			return false
		case .none:
			return true
		}
	}
}

/**
Equatable UIView.Direction
*/
public func ==(lhs: UIView.Direction, rhs: UIView.Direction) -> Bool {
	switch lhs {
	case .horizontally:
		switch rhs {
		case .horizontally:
			return true
		case .vertically:
			return false
		}
		
	case .vertically:
		switch rhs {
		case .horizontally:
			return false
		case .vertically:
			return true
		}
	}
}

/**
Equatable UIView.Visibility
*/
public func ==(lhs: UIView.Visibility, rhs: UIView.Visibility) -> Bool {
	switch lhs {
	case .visible:
		switch rhs {
		case .visible:
			return true
		default:
			return false
		}
		
	case .invisible:
		switch rhs {
		case .invisible:
			return true
		default:
			return false
		}
		
	case .gone(let lhsDirection, let lhsStick):
		switch rhs {
		case .gone(let rhsDirection, let rhsStick):
			return lhsDirection == rhsDirection && lhsStick == rhsStick
		default:
			return false
		}
	}
}


// MARK: - Private Extension
private extension UIView {

	struct AccociatedKeys {
		static var OriginalConstraints = "OriginalConstraints"
		static var ZeroConstraint = "ZeroConstraint"
		static var Visibility = "Visibility"
	}
	
	var originalConstraints: [NSLayoutConstraint]? {
		get {
			if let originalConstraints = objc_getAssociatedObject(self, &AccociatedKeys.OriginalConstraints) as? [NSLayoutConstraint] {
				return originalConstraints
			}
			return nil
		}
		set {
			objc_setAssociatedObject(self, &AccociatedKeys.OriginalConstraints, newValue, .OBJC_ASSOCIATION_COPY)
		}
	}
}


// MARK: - Public Extension
public extension UIView {

	
	public enum Stick: Equatable {
		case left
		case right
		case top
		case bottom
		case center
		case none
		
		public static var enums: [Stick] {
			get {
				let enums: [Stick] = [
					.left,
					.right,
					.top,
					.bottom,
					.center,
					.none,
					]
				return enums
			}
		}
		
		public func stringValue() -> String {
			switch self {
			case .left:
				return "Left"
			case .right:
				return "Right"
			case .top:
				return "Top"
			case .bottom:
				return "Bottom"
			case .center:
				return "Bottom"
			case .none:
				return "None"
			}
		}
	}

	public enum Direction: Equatable {
		case horizontally
		case vertically
		
		public static var enums: [Direction] {
			get {
				let enums: [Direction] = [
					.horizontally,
					.vertically,
					]
				return enums
			}
		}
		
		func stringValue() -> String {
			switch self {
			case .horizontally:
				return "Horizontally"
			case .vertically:
				return "Vertically"
			}
		}
	}
	
	public enum Visibility: Equatable {
		case visible
		case invisible
		case gone(Direction, to:Stick)
		
		public static var enums: [Visibility] {
			get {
				var enums: [Visibility] = [
					.visible,
					.invisible,
					]
				
				for direction in Direction.enums {
					for stick in Stick.enums {
						enums.append(.gone(direction, to: stick))
					}
				}
				
				return enums
			}
		}
		
		public func stringValue() -> String {
			switch self {
			case .visible:
				return "Visible"
			case .invisible:
				return "Invisible"
			case .gone(let direction, let stick):
				return "Gone(\(direction.stringValue()), \(stick.stringValue()))"
			}
		}
	}
	
	var visibility: Visibility {
		get {
			if let rawVisibility = objc_getAssociatedObject(self, &AccociatedKeys.Visibility) as? NSValue {
				var visibility = Visibility.visible
				rawVisibility.getValue(&visibility)
				return visibility
			}
			
			if isHidden {
				return .invisible
			}
			return .visible
		}
		set {
			if visibility == newValue {
				return
			}
			setVisibility(newValue)
		}
	}

	func setVisibility(_ newValue: Visibility, animated: Bool = true, completion: (() -> Void)? = nil) {

		// save the visibility
		var mutableNewValue = newValue
		let value = NSValue(bytes: &mutableNewValue, objCType: "@")
		objc_setAssociatedObject(self, &AccociatedKeys.Visibility, value, .OBJC_ASSOCIATION_RETAIN)
		
		// save original constraints
		if originalConstraints == nil {
			originalConstraints = constraints
		}
		
		// deactivate current constraints
		NSLayoutConstraint.deactivate(constraints)
		
		// acitivate original constraints
		if let originalConstraints = originalConstraints {
			NSLayoutConstraint.activate(originalConstraints)
		}
		
		var hidden = false
		
		switch newValue {
		case .visible:
			hidden = false
			
		case .invisible:
			hidden = true
			
		case .gone(let direction, let stick):
			hidden = true
			
			// deacitivate attributes
			var deacitivateAttributes: [NSLayoutAttribute]
			
			// activate attribute
			var activateAttribute = NSLayoutAttribute.notAnAttribute
			
			switch direction {
			case .horizontally:
				deacitivateAttributes = [
					.left,
					.right,
					.leading,
					.trailing,
					.width,
					.centerX,
					.lastBaseline,
					.firstBaseline,
					.leftMargin,
					.rightMargin,
					.leadingMargin,
					.trailingMargin,
					.centerXWithinMargins,
				]
				activateAttribute = .width
				
			case .vertically:
				deacitivateAttributes = [
					.top,
					.bottom,
					.height,
					.centerY,
					.topMargin,
					.bottomMargin,
					.centerYWithinMargins,
				]
				activateAttribute = .height
			}

			//
			// deactivate the constraints for the specified direction.
			//
			var deactivateConstraints = [NSLayoutConstraint]()
			for constraint in constraints {
				if deacitivateAttributes.contains(constraint.firstAttribute) {
					deactivateConstraints.append(constraint)
				}
			}
			NSLayoutConstraint.deactivate(deactivateConstraints)

			//
			// activate the constraints
			//
			var activateConstraints = [NSLayoutConstraint]()

			// 0 in the specified direction
			activateConstraints.append(
				NSLayoutConstraint(
					item: self,
					attribute: activateAttribute,
					relatedBy: .equal,
					toItem: nil,
					attribute: .notAnAttribute,
					multiplier: 1.0,
					constant: 0.0
				)
			)
			
			// sticky attribute
			if stick != .none {
				var stickyAttribute: NSLayoutAttribute
				switch stick {
				case .left:
					stickyAttribute = .leading
				case .right:
					stickyAttribute = .trailing
				case .top:
					stickyAttribute = .top
				case .bottom:
					stickyAttribute = .bottom
				case .center:
					switch direction {
					case .horizontally:
						stickyAttribute = .centerX
					case .vertically:
						stickyAttribute = .centerY
					}
				case .none:
					stickyAttribute = .notAnAttribute
				}
				
				// stick to the specified edge
				if let subview = self.subviews.first, stickyAttribute != .notAnAttribute {
					activateConstraints.append(
						NSLayoutConstraint(
							item: self,
							attribute: stickyAttribute,
							relatedBy: .equal,
							toItem: subview,
							attribute: stickyAttribute,
							multiplier: 1.0,
							constant: 0.0
						)
					)
				}
			}
			
			NSLayoutConstraint.activate(activateConstraints)
		}
		
		// animate
		if animated {
			let clipsToBounds = self.clipsToBounds
			self.clipsToBounds = true
			self.alpha = self.isHidden ? 0.0 : 1.0
			self.isHidden = false
			
			UIView.animate(withDuration: 0.25, animations:
				{
					[weak self = self] in
					self?.alpha = hidden ? 0.0 : 1.0
					self?.superview?.layoutIfNeeded()
					
				}, completion: {
					[weak self = self] (finished: Bool) in
					self?.clipsToBounds = clipsToBounds
					self?.isHidden = hidden
					completion?()
			})
		}
		else {
			self.isHidden = hidden
			completion?()
		}
	}
}
