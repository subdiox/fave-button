//
//  StarButton.swift
//  StarButton
//
//  Created by Daiki Okumura on 2015/07/09.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit

open class StarButton: UIButton {
    
    var tweenValues: [CGFloat]?
    fileprivate var imageShape: CAShapeLayer!
    var image: UIImage!

    @IBInspectable open var normalColor: UIColor! = UIColor(red: 136/255, green: 153/255, blue: 166/255, alpha: 1.0) {
        didSet {
            if (!isSelected) {
                imageShape.fillColor = normalColor.cgColor
            }
        }
    }
    @IBInspectable open var selectedColor: UIColor! = UIColor(red: 255/255, green: 172/255, blue: 51/255, alpha: 1.0) {
        didSet {
            if (isSelected) {
                imageShape.fillColor = selectedColor.cgColor
            }
        }
    }
    
    fileprivate var ringShape: CAShapeLayer!
    fileprivate var ringMask: CAShapeLayer!
    @IBInspectable open var ringColor: UIColor! = UIColor(red: 255/255, green: 172/255, blue: 51/255, alpha: 1.0) {
        didSet {
            ringShape.fillColor = ringColor.cgColor
        }
    }
    
    fileprivate var lines: [CAShapeLayer]!
    @IBInspectable open var lineColor: UIColor! = UIColor(red: 250/255, green: 120/255, blue: 68/255, alpha: 1.0) {
        didSet {
            for line in lines {
                line.strokeColor = lineColor.cgColor
            }
        }
    }
    
    fileprivate let ringTransform = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let ringMaskTransform = CAKeyframeAnimation(keyPath: "transform")
    fileprivate let lineStrokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
    fileprivate let lineStrokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
    fileprivate let lineOpacity = CAKeyframeAnimation(keyPath: "opacity")
    fileprivate let imageTransform = CAKeyframeAnimation(keyPath: "transform")
    
    override open var isSelected : Bool {
        didSet {
            if (isSelected != oldValue) {
                if isSelected {
                    imageShape.fillColor = selectedColor.cgColor
                } else {
                    deselect()
                }
            }
        }
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        applyInit()
    }
    
    public override convenience init(frame: CGRect) {
        self.init(frame: frame, image: UIImage())
        applyInit()
    }
    
    public init(frame: CGRect, image: UIImage!) {
        super.init(frame: frame)
        self.image = image
        applyInit()
        addTargets()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        applyInit()
        addTargets()
    }
    
    fileprivate func createLayers(image: UIImage!) {
        self.layer.sublayers = nil
        
        let imageFrame = frame.size.scaleBy(1.0).rectCentered(at: frame.center)
        let maskFrame = frame.size.scaleBy(0.7).rectCentered(at: frame.center)
        let ringFrame = frame.size.scaleBy(0.9).rectCentered(at: frame.center)
        let imgCenterPoint = CGPoint(x: imageFrame.midX, y: imageFrame.midY)
        let lineFrame = frame.size.scaleBy(1.05).rectCentered(at: frame.center)
        
        //===============
        // ring layer
        //===============
        ringShape = CAShapeLayer()
        ringShape.bounds = ringFrame
        ringShape.position = imgCenterPoint
        ringShape.path = UIBezierPath(ovalIn: ringFrame).cgPath
        ringShape.fillColor = ringColor.cgColor
        ringShape.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        self.layer.addSublayer(ringShape)
        
        ringMask = CAShapeLayer()
        ringMask.bounds = ringFrame
        ringMask.position = imgCenterPoint
        ringMask.fillRule = kCAFillRuleEvenOdd
        ringShape.mask = ringMask
        
        let maskPath = UIBezierPath(rect: ringFrame)
        maskPath.addArc(withCenter: imgCenterPoint, radius: 0.1, startAngle: CGFloat(0.0), endAngle: .pi * 2, clockwise: true)
        ringMask.path = maskPath.cgPath
        
        //===============
        // line layer
        //===============
        lines = []
        for i in 0 ..< 5 {
            let line = CAShapeLayer()
            line.bounds = lineFrame
            line.position = imgCenterPoint
            line.masksToBounds = true
            line.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
            line.strokeColor = lineColor.cgColor
            line.lineWidth = 1.25
            line.miterLimit = 1.25
            line.path = {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: lineFrame.midX, y: lineFrame.midY))
                path.addLine(to: CGPoint(x: lineFrame.origin.x + lineFrame.width / 2, y: lineFrame.origin.y))
                return path
            }()
            line.lineCap = kCALineCapRound
            line.lineJoin = kCALineJoinRound
            line.strokeStart = 0.0
            line.strokeEnd = 0.0
            line.opacity = 0.0
            line.transform = CATransform3DMakeRotation(.pi / 5 * (CGFloat(i) * 2 + 1), 0.0, 0.0, 1.0)
            self.layer.addSublayer(line)
            lines.append(line)
        }
        
        //===============
        // image layer
        //===============
        imageShape = CAShapeLayer()
        imageShape.bounds = imageFrame
        imageShape.position = imgCenterPoint
        imageShape.path = UIBezierPath(rect: imageFrame).cgPath
        imageShape.fillColor = normalColor.cgColor
        imageShape.actions = ["fillColor": NSNull()]
        self.layer.addSublayer(imageShape)
        
        imageShape.mask = CALayer()
        imageShape.mask!.contents = image.cgImage
        imageShape.mask!.bounds = maskFrame
        imageShape.mask!.position = imgCenterPoint
        
        //==============================
        // ring transform animation
        //==============================
        ringTransform.duration = 0.333 // 0.0333 * 10
        ringTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,  0.0,  1.0)),    //  0/10
            NSValue(caTransform3D: CATransform3DMakeScale(0.5,  0.5,  1.0)),    //  1/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.0,  1.0,  1.0)),    //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,  1.2,  1.0)),    //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.3,  1.3,  1.0)),    //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.37, 1.37, 1.0)),    //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0)),    //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(1.4,  1.4,  1.0))     // 10/10
        ]
        ringTransform.keyTimes = [
            0.0,    //  0/10
            0.1,    //  1/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            1.0     // 10/10
        ]
        
        ringMaskTransform.duration = 0.333 // 0.0333 * 10
        ringMaskTransform.values = [
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  0/10
            NSValue(caTransform3D: CATransform3DIdentity),                                                              //  2/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 1.25,  imageFrame.height * 1.25,  1.0)),   //  3/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 2.688, imageFrame.height * 2.688, 1.0)),   //  4/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 3.923, imageFrame.height * 3.923, 1.0)),   //  5/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.375, imageFrame.height * 4.375, 1.0)),   //  6/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 4.731, imageFrame.height * 4.731, 1.0)),   //  7/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0)),   //  9/10
            NSValue(caTransform3D: CATransform3DMakeScale(imageFrame.width * 5.0,   imageFrame.height * 5.0,   1.0))    // 10/10
        ]
        ringMaskTransform.keyTimes = [
            0.0,    //  0/10
            0.2,    //  2/10
            0.3,    //  3/10
            0.4,    //  4/10
            0.5,    //  5/10
            0.6,    //  6/10
            0.7,    //  7/10
            0.9,    //  9/10
            1.0     // 10/10
        ]
        
        //==============================
        // line stroke animation
        //==============================
        lineStrokeStart.duration = 0.6 //0.0333 * 18
        lineStrokeStart.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.18,   //  2/18
            0.2,    //  3/18
            0.26,   //  4/18
            0.32,   //  5/18
            0.4,    //  6/18
            0.6,    //  7/18
            0.71,   //  8/18
            0.89,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeStart.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.333,  //  6/18
            0.389,  //  7/18
            0.444,  //  8/18
            0.944,  // 17/18
            1.0,    // 18/18
        ]
        
        lineStrokeEnd.duration = 0.6 //0.0333 * 18
        lineStrokeEnd.values = [
            0.0,    //  0/18
            0.0,    //  1/18
            0.32,   //  2/18
            0.48,   //  3/18
            0.64,   //  4/18
            0.68,   //  5/18
            0.92,   // 17/18
            0.92    // 18/18
        ]
        lineStrokeEnd.keyTimes = [
            0.0,    //  0/18
            0.056,  //  1/18
            0.111,  //  2/18
            0.167,  //  3/18
            0.222,  //  4/18
            0.278,  //  5/18
            0.944,  // 17/18
            1.0,    // 18/18
        ]
        
        lineOpacity.duration = 1.0 //0.0333 * 30
        lineOpacity.values = [
            1.0,    //  0/30
            1.0,    // 12/30
            0.0     // 17/30
        ]
        lineOpacity.keyTimes = [
            0.0,    //  0/30
            0.4,    // 12/30
            0.567   // 17/30
        ]
        
        //==============================
        // image transform animation
        //==============================
        imageTransform.duration = 1.0 //0.0333 * 30
        imageTransform.values = [
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  0/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.0,   0.0,   1.0)),  //  3/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  //  9/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.25,  1.25,  1.0)),  // 10/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.2,   1.2,   1.0)),  // 11/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 14/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 15/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.875, 0.875, 1.0)),  // 16/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.9,   0.9,   1.0)),  // 17/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 20/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.025, 1.025, 1.0)),  // 21/30
            NSValue(caTransform3D: CATransform3DMakeScale(1.013, 1.013, 1.0)),  // 22/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 25/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.95,  0.95,  1.0)),  // 26/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.96,  0.96,  1.0)),  // 27/30
            NSValue(caTransform3D: CATransform3DMakeScale(0.99,  0.99,  1.0)),  // 29/30
            NSValue(caTransform3D: CATransform3DIdentity)                       // 30/30
        ]
        imageTransform.keyTimes = [
            0.0,    //  0/30
            0.1,    //  3/30
            0.3,    //  9/30
            0.333,  // 10/30
            0.367,  // 11/30
            0.467,  // 14/30
            0.5,    // 15/30
            0.533,  // 16/30
            0.567,  // 17/30
            0.667,  // 20/30
            0.7,    // 21/30
            0.733,  // 22/30
            0.833,  // 25/30
            0.867,  // 26/30
            0.9,    // 27/30
            0.967,  // 29/30
            1.0     // 30/30
        ]
    }
    
    fileprivate func applyInit(){
        if nil == image {
            image = image(for: UIControlState())
        }
        
        guard let _ = image else {
            fatalError("please provide an image for normal state.")
        }
        
        setImage(UIImage(), for: UIControlState())
        setImage(UIImage(), for: .selected)
        setTitle(nil, for: UIControlState())
        setTitle(nil, for: .selected)
        
        createLayers(image: image)
    }
    
    fileprivate func addTargets() {
        //===============
        // add target
        //===============
        self.addTarget(self, action: #selector(StarButton.touchDown(_:)), for: UIControlEvents.touchDown)
        self.addTarget(self, action: #selector(StarButton.touchUpInside(_:)), for: UIControlEvents.touchUpInside)
        self.addTarget(self, action: #selector(StarButton.touchDragExit(_:)), for: UIControlEvents.touchDragExit)
        self.addTarget(self, action: #selector(StarButton.touchDragEnter(_:)), for: UIControlEvents.touchDragEnter)
        self.addTarget(self, action: #selector(StarButton.touchCancel(_:)), for: UIControlEvents.touchCancel)
    }
    
    @objc func touchDown(_ sender: StarButton) {
        self.layer.opacity = 0.4
    }
    @objc func touchUpInside(_ sender: StarButton) {
        self.layer.opacity = 1.0
    }
    @objc func touchDragExit(_ sender: StarButton) {
        self.layer.opacity = 1.0
    }
    @objc func touchDragEnter(_ sender: StarButton) {
        self.layer.opacity = 0.4
    }
    @objc func touchCancel(_ sender: StarButton) {
        self.layer.opacity = 1.0
    }
    
    open func toggle() {
        if isSelected {
            deselect()
        } else {
            select()
        }
    }
    
    private func select() {
        isSelected = true
        imageShape.fillColor = selectedColor.cgColor
        
        CATransaction.begin()
        
        ringShape.add(ringTransform, forKey: "transform")
        ringMask.add(ringMaskTransform, forKey: "transform")
        imageShape.add(imageTransform, forKey: "transform")
        
        for i in 0 ..< 5 {
            lines[i].add(lineStrokeStart, forKey: "strokeStart")
            lines[i].add(lineStrokeEnd, forKey: "strokeEnd")
            lines[i].add(lineOpacity, forKey: "opacity")
        }
        
        CATransaction.commit()
    }
    
    private func deselect() {
        isSelected = false
        animateDeselect()
        
        // remove all animations
        ringShape.removeAllAnimations()
        ringMask.removeAllAnimations()
        imageShape.removeAllAnimations()
        lines[0].removeAllAnimations()
        lines[1].removeAllAnimations()
        lines[2].removeAllAnimations()
        lines[3].removeAllAnimations()
        lines[4].removeAllAnimations()
    }
    
    func animateDeselect(_ duration: Double = 0.5, delay: Double = 0){
        if nil == tweenValues{
            tweenValues = generateTweenValues(from: 0, to: 1.0, duration: CGFloat(duration))
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageShape.fillColor = normalColor.cgColor
        CATransaction.commit()
        
        let selectedDelay = isSelected ? delay : 0
        
        let scaleAnimation = Init(CAKeyframeAnimation(keyPath: "transform.scale")){
            $0.values    = tweenValues!
            $0.duration  = duration
            $0.beginTime = CACurrentMediaTime()+selectedDelay
        }
        imageShape.mask?.add(scaleAnimation, forKey: nil)
    }
    
    func generateTweenValues(from: CGFloat, to: CGFloat, duration: CGFloat) -> [CGFloat]{
        var values         = [CGFloat]()
        let fps            = CGFloat(60.0)
        let tpf            = duration/fps
        let c              = to-from
        let d              = duration
        var t              = CGFloat(0.0)
        let tweenFunction  = Elastic.ExtendedEaseOut
        
        while(t < d){
            let scale = tweenFunction(t, from, c, d, c+0.001, 0.39988)  // p=oscillations, c=amplitude(velocity)
            values.append(scale)
            t += tpf
        }
        return values
    }
}