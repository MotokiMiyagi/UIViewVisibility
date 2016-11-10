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
	case .Left:
		switch rhs {
		case .Left:
			return true
		case .Right:
			return false
		case .Top:
			return false
		case .Bottom:
			return false
		case .Center:
			return false
		case .None:
			return false
		}
	case .Right:
		switch rhs {
		case .Left:
			return false
		case .Right:
			return true
		case .Top:
			return false
		case .Bottom:
			return false
		case .Center:
			return false
		case .None:
			return false
		}
	case .Top:
		switch rhs {
		case .Left:
			return false
		case .Right:
			return false
		case .Top:
			return true
		case .Bottom:
			return false
		case .Center:
			return false
		case .None:
			return false
		}
	case .Bottom:
		switch rhs {
		case .Left:
			return false
		case .Right:
			return false
		case .Top:
			return false
		case .Bottom:
			return true
		case .Center:
			return false
		case .None:
			return false
		}
	case .Center:
		switch rhs {
		case .Left:
			return false
		case .Right:
			return false
		case .Top:
			return false
		case .Bottom:
			return false
		case .Center:
			return true
		case .None:
			return false
		}
	case .None:
		switch rhs {
		case .Left:
			return false
		case .Right:
			return false
		case .Top:
			return false
		case .Bottom:
			return false
		case .Center:
			return false
		case .None:
			return true
		}
	}
}

/**
Equatable UIView.Direction
*/
public func ==(lhs: UIView.Direction, rhs: UIView.Direction) -> Bool {
	switch lhs {
	case .Horizontally:
		switch rhs {
		case .Horizontally:
			return true
		case .Vertically:
			return false
		}
		
	case .Vertically:
		switch rhs {
		case .Horizontally:
			return false
		case .Vertically:
			return true
		}
	}
}

/**
Equatable UIView.Visibility
*/
public func ==(lhs: UIView.Visibility, rhs: UIView.Visibility) -> Bool {
	switch lhs {
	case .Visible:
		switch rhs {
		case .Visible:
			return true
		default:
			return false
		}
		
	case .Invisible:
		switch rhs {
		case .Invisible:
			return true
		default:
			return false
		}
		
	case .Gone(let lhsDirection, let lhsStick):
		switch rhs {
		case .Gone(let rhsDirection, let rhsStick):
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

	public enum Stick : Equatable {
		case Left
		case Right
		case Top
		case Bottom
		case Center
		case None
		
		public static var enums: [Stick] {
			get {
				let enums: [Stick] = [
					.Left,
					.Right,
					.Top,
					.Bottom,
					.Center,
					.None,
					]
				return enums
			}
		}
		
		func stringValue() -> String {
			switch self {
			case .Left:
				return "Left"
			case .Right:
				return "Right"
			case .Top:
				return "Top"
			case .Bottom:
				return "Bottom"
			case .Center:
				return "Bottom"
			case .None:
				return "None"
			}
		}
	}

	enum Direction: Equatable {
		case Horizontally
		case Vertically
		
		public static var enums: [Direction] {
			get {
				let enums: [Direction] = [
					.Horizontally,
					.Vertically,
					]
				return enums
			}
		}
		
		func stringValue() -> String {
			switch self {
			case .Horizontally:
				return "Horizontally"
			case .Vertically:
				return "Vertically"
			}
		}
	}
	
	enum Visibility: Equatable {
		case Visible
		case Invisible
		case Gone(Direction, to:Stick)
	
		public static var enums: [Visibility] {
			get {
				var enums: [Visibility] = [
					.Visible,
					.Invisible,
					]
				
				for direction in Direction.enums {
					for stick in Stick.enums {
						enums.append(.Gone(direction, to: stick))
					}
				}
				
				return enums
			}
		}
		
		public func stringValue() -> String {
			switch self {
			case .Visible:
				return "Visible"
			case .Invisible:
				return "Invisible"
			case .Gone(let direction, let stick):
				return "Gone(\(direction.stringValue()), \(stick.stringValue()))"
			}
		}
	}
	
	
	var visibility: Visibility {
		get {
			if let rawVisibility = objc_getAssociatedObject(self, &AccociatedKeys.Visibility) as? NSValue {
				var visibility = Visibility.Visible
				rawVisibility.getValue(&visibility)
				return visibility
			}
			
			if hidden {
				return .Invisible
			}
			return .Visible
		}
		set {
			if visibility == newValue {
				return
			}
			setVisibility(newValue)
		}
	}

	func setVisibility(newValue: Visibility, animated: Bool = true, completion: (() -> Void)? = nil) {

		// save the visibility
		var mutableNewValue = newValue
		let value = NSValue(bytes: &mutableNewValue, objCType: "@")
		objc_setAssociatedObject(self, &AccociatedKeys.Visibility, value, .OBJC_ASSOCIATION_RETAIN)
		
		// save original constraints
		if originalConstraints == nil {
			originalConstraints = constraints
		}
		
		// deactivate current constraints
		NSLayoutConstraint.deactivateConstraints(constraints)
		
		// acitivate original constraints
		if let originalConstraints = originalConstraints {
			NSLayoutConstraint.activateConstraints(originalConstraints)
		}
		
		var hidden = false
		
		switch newValue {
		case .Visible:
			hidden = false
			
		case .Invisible:
			hidden = true
			
		case .Gone(let direction, let stick):
			hidden = true
			
			// deacitivate attributes
			var deacitivateAttributes: [NSLayoutAttribute]
			
			// activate attribute
			var activateAttribute = NSLayoutAttribute.NotAnAttribute
			
			switch direction {
			case .Horizontally:
				deacitivateAttributes = [
					.Left,
					.Right,
					.Leading,
					.Trailing,
					.Width,
					.CenterX,
					.Baseline,
					.FirstBaseline,
					.LeftMargin,
					.RightMargin,
					.LeadingMargin,
					.TrailingMargin,
					.CenterXWithinMargins,
				]
				activateAttribute = .Width
				
			case .Vertically:
				deacitivateAttributes = [
					.Top,
					.Bottom,
					.Height,
					.CenterY,
					.TopMargin,
					.BottomMargin,
					.CenterYWithinMargins,
				]
				activateAttribute = .Height
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
			NSLayoutConstraint.deactivateConstraints(deactivateConstraints)

			//
			// activate the constraints
			//
			var activateConstraints = [NSLayoutConstraint]()

			// 0 in the specified direction
			activateConstraints.append(
				NSLayoutConstraint(
					item: self,
					attribute: activateAttribute,
					relatedBy: .Equal,
					toItem: nil,
					attribute: .NotAnAttribute,
					multiplier: 1.0,
					constant: 0.0
				)
			)
			
			// sticky attribute
			if stick != .None {
				var stickyAttribute: NSLayoutAttribute
				switch stick {
				case .Left:
					stickyAttribute = .Leading
				case .Right:
					stickyAttribute = .Trailing
				case .Top:
					stickyAttribute = .Top
				case .Bottom:
					stickyAttribute = .Bottom
				case .Center:
					switch direction {
					case .Horizontally:
						stickyAttribute = .CenterX
					case .Vertically:
						stickyAttribute = .CenterY
					}
				case .None:
					stickyAttribute = .NotAnAttribute
				}
				
				// stick to the specified edge
				if let subview = self.subviews.first where stickyAttribute != .NotAnAttribute {
					activateConstraints.append(
						NSLayoutConstraint(
							item: self,
							attribute: stickyAttribute,
							relatedBy: .Equal,
							toItem: subview,
							attribute: stickyAttribute,
							multiplier: 1.0,
							constant: 0.0
						)
					)
				}
			}
			
			NSLayoutConstraint.activateConstraints(activateConstraints)
		}
		
		// animate
		if animated {
			var clipsToBounds = self.clipsToBounds
			self.clipsToBounds = true
			self.alpha = self.hidden ? 0.0 : 1.0
			self.hidden = false
			
			UIView.animateWithDuration(0.25, animations:
				{
					[weak self = self] in
					self?.alpha = hidden ? 0.0 : 1.0
					self?.superview?.layoutIfNeeded()
					
				}, completion: {
					[weak self = self] (finished: Bool) in
					self?.clipsToBounds = clipsToBounds
					self?.hidden = hidden
					completion?()
			})
		}
		else {
			self.hidden = hidden
			completion?()
		}
	}
}
