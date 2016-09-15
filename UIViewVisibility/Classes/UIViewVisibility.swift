//
//  UIViewVisibility.swift
//  Pods
//
//  Created by Motoki Miyagi on 2016/09/15.
//
//

import UIKit


// MARK: - Operator Overload
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
		
	case .Gone(let lhsDirection):
		switch rhs {
		case .Gone(let rhsDirection):
			return lhsDirection == rhsDirection
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
	
	var zeroConstraint: NSLayoutConstraint? {
		get {
			if let zeroConstraint = objc_getAssociatedObject(self, &AccociatedKeys.ZeroConstraint) as? NSLayoutConstraint {
				return zeroConstraint
			}
			return nil
		}
		set {
			objc_setAssociatedObject(self, &AccociatedKeys.ZeroConstraint, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
}


// MARK: - Public Extension
public extension UIView {
	
	enum Direction: Equatable {
		case Horizontally
		case Vertically
	}
	
	enum Visibility: Equatable {
		case Visible
		case Invisible
		case Gone(Direction)
		
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
			
			// visibilityを保存
			var mutableNewValue = newValue
			let value = NSValue(bytes: &mutableNewValue, objCType: "@")
			objc_setAssociatedObject(self, &AccociatedKeys.Visibility, value, .OBJC_ASSOCIATION_RETAIN)
			
			// 元々の制約を退避
			if originalConstraints == nil {
				originalConstraints = constraints
			}
			
			// ゼロの制約があれば無効にする
			if let zeroConstraint = zeroConstraint {
				NSLayoutConstraint.deactivateConstraints([zeroConstraint])
				self.zeroConstraint = nil
			}
			
			// 元々の制約に戻す
			if let originalConstraints = originalConstraints {
				NSLayoutConstraint.activateConstraints(originalConstraints)
			}
			
			switch newValue {
			case .Visible:
				hidden = false
				
			case .Invisible:
				hidden = true
				
			case .Gone(let direction):
				hidden = true
				
				// そのままにしておく属性（方向）
				var remainingAttribute = NSLayoutAttribute.NotAnAttribute
				
				// 有効にする属性（ゼロにする方向）
				var activateAttribute = NSLayoutAttribute.NotAnAttribute
				
				switch direction {
				case .Horizontally:
					remainingAttribute = .Height
					activateAttribute = .Width
					
				case .Vertically:
					remainingAttribute = .Width
					activateAttribute = .Height
				}
				
				// 指定された方向以外の制約をはずす
				NSLayoutConstraint.deactivateConstraints(constraints.filter({ (constraint: NSLayoutConstraint) -> Bool in
					if constraint.firstAttribute != remainingAttribute {
						return true
					}
					return false
				}))
				
				// 指定された方向に0になる制約を付ける
				let zeroConstraint = NSLayoutConstraint(
					item: self,
					attribute: activateAttribute,
					relatedBy: .Equal,
					toItem: nil,
					attribute: .NotAnAttribute,
					multiplier: 1.0,
					constant: 0
				)
				NSLayoutConstraint.activateConstraints([zeroConstraint])
				self.zeroConstraint = zeroConstraint
			}
			
			// 制約を更新するようにする
			superview?.setNeedsUpdateConstraints()
		}
	}
}
