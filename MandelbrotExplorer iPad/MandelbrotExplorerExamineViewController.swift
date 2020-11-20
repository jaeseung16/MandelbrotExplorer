//
//  MandelbrotExplorerExamineViewController.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/26/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit
import ComplexModule

class MandelbrotExplorerExamineViewController: UIViewController {
    @IBOutlet weak var mandelbrotIUIView: MandelbrotUIView!
    @IBOutlet weak var exploreBarButton: UIBarButtonItem!
    
    @IBOutlet weak var realMinTextField: UITextField!
    @IBOutlet weak var realMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMaxTextField: UITextField!
    @IBOutlet weak var imaginaryMinTextField: UITextField!
    
    @IBOutlet weak var maxIterLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var mandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = MandelbrotConstant.sideLength
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    
    var dataController: DataController?
    var mandelbrotEntity: MandelbrotEntity?
    
    var maxIter = MaxIter.twoHundred.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let entity = mandelbrotEntity, isTooSmallToExplore(entity) {
            statusLabel.isHidden = false
            exploreBarButton.isEnabled = false
        } else {
            statusLabel.isHidden = true
            exploreBarButton.isEnabled = mandelbrotEntity != nil
        }
        
        let rotationAngle = CGFloat(-1.0 * Double.pi / 2.0)
        rotateAndAdjustPostion(realMinTextField, rotationAngle: rotationAngle, translationX: CGFloat(30.0))
        rotateAndAdjustPostion(realMaxTextField, rotationAngle: rotationAngle, translationX: CGFloat(-30.0))
        
    }
    
    private func rotateAndAdjustPostion(_ textField: UITextField, rotationAngle: CGFloat, translationX: CGFloat) -> Void {
        textField.transform = CGAffineTransform(rotationAngle: rotationAngle)
            .concatenating(CGAffineTransform(translationX: translationX, y: CGFloat(0.0)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeDefaultMandelbrotDisplay()
        initializeDefaultMandelbrotView()
        initializeTextFields()
        
        if let entity = mandelbrotEntity {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            maxIterLabel.text = "max iteration: \(entity.maxIter)"
            createdLabel.text = "created on \(dateFormatter.string(from: entity.created!))"
            hideLabels(false)
            hideTextField(false)
        } else {
            hideLabels(true)
            hideTextField(true)
        }
    }
    
    private func hideLabels(_ isHidden: Bool) {
        maxIterLabel.isHidden = isHidden
        createdLabel.isHidden = isHidden
    }
    
    private func hideTextField(_ isHidden: Bool) {
        realMinTextField.isHidden = isHidden
        realMaxTextField.isHidden = isHidden
        imaginaryMaxTextField.isHidden = isHidden
        imaginaryMinTextField.isHidden = isHidden
    }
    
    private func isTooSmallToExplore(_ entity: MandelbrotEntity) -> Bool {
        maxIter = Int(entity.maxIter)
        
        let diffReal = Float(entity.maxReal - entity.minReal)
        let diffImaginary = Float(entity.maxImaginary - entity.minImaginary)
        let allowedDiff = Float.ulpOfOne * Float(sideLength) / 2.0
        
        return diffReal < allowedDiff || diffImaginary < allowedDiff
    }
    
    func initializeDefaultMandelbrotDisplay() {
        mandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength, maxIter: maxIter)
        mandelbrotDisplay?.id = MandelbrotID.first
        mandelbrotDisplay?.maxIter = maxIter
        
        if (mandelbrotEntity == nil) {
            let mandelbrotExplorerColorMap = MandelbrotExplorerColorMap.jet
            mandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(mandelbrotExplorerColorMap,
                                                                      length: MaxIter(rawValue: maxIter)!.normalize())
                .colorMapInSIMD4
            mandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        } else {
            let minReal = mandelbrotEntity!.minReal
            let maxReal = mandelbrotEntity!.maxReal
            let minImaginary = mandelbrotEntity!.minImaginary
            let maxImaginary = mandelbrotEntity!.maxImaginary
            
            let mandelbrotExplorerColorMap = MandelbrotExplorerColorMap(rawValue: mandelbrotEntity!.colorMap!)
            mandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(mandelbrotExplorerColorMap!,
                                                                      length: MaxIter(rawValue: maxIter)!.normalize())
                .colorMapInSIMD4
            
            let mandelbrotRect = ComplexRect(Complex<Double>(minReal, minImaginary), Complex<Double>(maxReal, maxImaginary))
            
            mandelbrotDisplay?.mandelbrotRect = mandelbrotRect
        }
        
        mandelbrotDisplay?.generateMandelbrotSet()
    }
    
    func initializeDefaultMandelbrotView() {
        mandelbrotIUIView.id = MandelbrotID.first
        mandelbrotIUIView.mandelbrotImage = mandelbrotDisplay?.mandelbrotImage
        mandelbrotIUIView.mandelbrotRect = defaultMandelbrotRect
        mandelbrotIUIView.rectScale = 1.0
    }

    func initializeTextFields() {
        if let mandelbrotDisplay = mandelbrotDisplay {
            let format = "%.6f"
            realMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minReal)
            realMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxReal)
            imaginaryMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minImaginary)
            imaginaryMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxImaginary)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mandelbrotExplorerDetailViewController = segue.destination as? MandelbrotExplorerDetailViewController {
            mandelbrotExplorerDetailViewController.dataController = dataController
            mandelbrotExplorerDetailViewController.defaultMandelbrotEntity = mandelbrotEntity
        }
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let entity = mandelbrotEntity, let image = mandelbrotIUIView.mandelbrotImage else {
            NSLog("mandelbrotEntity = \(String(describing: mandelbrotEntity))")
            NSLog("mandelbrotIUIView.mandelbrotImage = \(String(describing: mandelbrotIUIView.mandelbrotImage))")
            return
        }
        
        guard let mandelbrotShareUIView = Bundle.main.loadNibNamed("MandelbrotShareUIView", owner: self, options: nil)![0] as? MandelbrotShareUIView else {
            NSLog("Cannot initialize MandelbrotShare")
            return
        }
        
        setup(mandelbrotShareUIView, entity: entity, image: image)
        
        let renderer = UIGraphicsImageRenderer(size: mandelbrotShareUIView.bounds.size)
        let renderedImage = renderer.image { ctx in
            mandelbrotShareUIView.drawHierarchy(in: mandelbrotShareUIView.bounds, afterScreenUpdates: true)
        }
        
        let activityItems: [Any] = [renderedImage]
        
        present(sender, activityItems)
    }
    
    private func setup(_ mandelbrotShareUIView: MandelbrotShareUIView, entity: MandelbrotEntity, image: UIImage) {
        let rotationAngle = CGFloat(-1.0 * Double.pi / 2.0)
        rotateAndAdjustPostion(mandelbrotShareUIView.realMinTextField, rotationAngle: rotationAngle, translationX: CGFloat(-30.0))
        rotateAndAdjustPostion(mandelbrotShareUIView.realMaxTextField, rotationAngle: rotationAngle, translationX: CGFloat(30.0))
        
        mandelbrotShareUIView.mandelbrotIUIView.mandelbrotImage = image
        
        if let mandelbrotDisplay = mandelbrotDisplay {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            mandelbrotShareUIView.maxIterLabel.text = "max iteration: \(entity.maxIter)"
            mandelbrotShareUIView.createdLabel.text = "created on \(dateFormatter.string(from: entity.created!))"
            
            let format = "%.6f"
            mandelbrotShareUIView.realMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minReal)
            mandelbrotShareUIView.realMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxReal)
            mandelbrotShareUIView.imaginaryMinTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.minImaginary)
            mandelbrotShareUIView.imaginaryMaxTextField.text = String(format: format, mandelbrotDisplay.mandelbrotRect.maxImaginary)
        }
    }
    
    private func present(_ sender: UIBarButtonItem, _ activityItems: [Any]) -> Void {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.assignToContact,
                                                        UIActivity.ActivityType.openInIBooks,
                                                        UIActivity.ActivityType.saveToCameraRoll]
        
        present(activityViewController, animated: true)
    }
    
}
