//
//  HoleOverlayViewController.swift
//  GooBike
//
//  Created by m-miyagi on 2016/09/16.
//
//

import UIKit

class HoleOverlayViewController: UIViewController {

	var holeOverlayView: HoleOverlayView! {
		return view as! HoleOverlayView
	}
	
	/**
	HoleOverlayViewControllerをインスタンス化する
	- returns: HoleOverlayViewControllerのインスタンスを返す
	*/
	class func instantiate() -> HoleOverlayViewController? {
		let className = "HoleOverlayViewController"
		let storyboard = UIStoryboard(name: className, bundle: nil)
		return storyboard.instantiateViewControllerWithIdentifier(className) as? HoleOverlayViewController
	}
	
	func attachToViewController(parentViewController: UIViewController) {
		guard let window = parentViewController.view?.window else {
			return
		}
		
		parentViewController.addChildViewController(self)
		parentViewController.view.addSubview(self.view)

		if UIApplication.sharedApplication().applicationState == .Background {
			window.layoutIfNeeded()
		}
		
		self.didMoveToParentViewController(parentViewController)
	}

}


@IBDesignable
class HoleOverlayView: UIView {

	@IBInspectable var holeCenter: CGPoint = CGPointZero {
		didSet {
			setNeedsDisplay()
		}
	}

	@IBInspectable var holeStartRadius: CGFloat = 0.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	@IBInspectable var holeEndRadius: CGFloat = 0.0 {
		didSet {
			setNeedsDisplay()
		}
	}
	
	override var alpha: CGFloat {
		didSet {
			blurFilterMask.alpha = alpha
		}
	}
	
	let blurFilterMask = BlurFilterMask()

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)

		blurFilterMask.frame = bounds
		blurFilterMask.shouldRasterize = true
		
		blurFilterMask.startCenter = holeCenter
		blurFilterMask.startRadius = holeStartRadius
		blurFilterMask.endCenter = holeCenter
		blurFilterMask.endRadius = holeEndRadius
		
		layer.mask = blurFilterMask
		blurFilterMask.setNeedsDisplay()
	}
	
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, withEvent: event)
		
		if hitView == self && isInsideHole(point) {
			return nil
		}
		
		return hitView
	}

	func isInsideHole(point: CGPoint) -> Bool {
		let distance = sqrt(pow(holeCenter.x - point.x, 2) + pow(holeCenter.y - point.y, 2))
		return distance <= holeEndRadius
	}
}

class BlurFilterMask : CALayer {
	
	var startCenter = CGPointZero
	var startRadius: CGFloat = 0.0
	var endCenter = CGPointZero
	var endRadius: CGFloat = 0.0
	var alpha: CGFloat = 0.0

	override func drawInContext(ctx: CGContext) {

		let space = CGColorSpaceCreateDeviceRGB();
		
		let components : [CGFloat] = [
			0.0, 0.0, 0.0, 0.0,
			0.0, 0.0, 0.0, alpha,
		]
		
		let locations : [CGFloat] = [0.0, 1.0]
		
		let gradient = CGGradientCreateWithColorComponents(space, components, locations, locations.count)
		
		CGContextDrawRadialGradient(
			ctx,
			gradient,
			startCenter,
			startRadius,
			endCenter,
			endRadius,
			.DrawsAfterEndLocation
		)
	}
}
