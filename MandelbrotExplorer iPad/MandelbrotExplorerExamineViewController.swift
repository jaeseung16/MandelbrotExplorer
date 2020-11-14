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
    
    var mandelbrotDisplay: MandelbrotDisplayIPad?
    
    let sideLength = 383
    let rectScale: CGFloat = 1.0
    let blockiness: CGFloat = 1.0
    let defaultMandelbrotRect = ComplexRect(Complex<Double>(-2.1, -1.5), Complex<Double>(0.9, 1.5))
    
    var mandelbrotImageGenerator: MandelbrotImageGenerator?
    
    var dataController: DataController?
    var mandelbrotEntity: MandelbrotEntity?
    
    var maxIter = MaxIter.twoHundred.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        maxIterLabel.isHidden = true
        createdLabel.isHidden = true
        
        exploreBarButton.isEnabled = mandelbrotEntity != nil
        
        realMinTextField.transform = CGAffineTransform(rotationAngle: CGFloat(-1.0 * Double.pi / 2.0))
            .concatenating(CGAffineTransform(translationX: CGFloat(30.0), y: CGFloat(0.0)))
        realMaxTextField.transform = CGAffineTransform(rotationAngle: CGFloat(-1.0 * Double.pi / 2.0))
            .concatenating(CGAffineTransform(translationX: CGFloat(-30.0), y: CGFloat(0.0)))
        
        if (mandelbrotEntity != nil) {
            maxIter = Int(mandelbrotEntity!.maxIter)
        }
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
            maxIterLabel.isHidden = false
            
            createdLabel.text = "created on \(dateFormatter.string(from: entity.created!))"
            createdLabel.isHidden = false
        } else {
            maxIterLabel.isHidden = true
            createdLabel.isHidden = true
        }
    }
    
    func initializeDefaultMandelbrotDisplay() {
        print("maxIter = \(maxIter)")
        mandelbrotDisplay = MandelbrotDisplayIPad(sideLength: sideLength, maxIter: maxIter)
        mandelbrotDisplay?.id = MandelbrotID.first
        mandelbrotDisplay?.maxIter = maxIter
        
        if (mandelbrotEntity == nil) {
            let mandelbrotExplorerColorMap = MandelbrotExplorerColorMap.green
            mandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(mandelbrotExplorerColorMap, length: maxIter).colorMapInSIMD4
            mandelbrotDisplay?.mandelbrotRect = defaultMandelbrotRect
        } else {
            let minReal = mandelbrotEntity!.minReal
            let maxReal = mandelbrotEntity!.maxReal
            let minImaginary = mandelbrotEntity!.minImaginary
            let maxImaginary = mandelbrotEntity!.maxImaginary
            
            let mandelbrotExplorerColorMap = MandelbrotExplorerColorMap(rawValue: mandelbrotEntity!.colorMap!)
            mandelbrotDisplay?.colorMap = ColorMapFactory.getColorMap(mandelbrotExplorerColorMap!, length: maxIter > 8192 ? 8192 : maxIter).colorMapInSIMD4
            
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
            realMinTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.minReal)
            realMaxTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.maxReal)
            imaginaryMinTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.minImaginary)
            imaginaryMaxTextField.text = String(format: "%.6f", mandelbrotDisplay.mandelbrotRect.maxImaginary)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let mandelbrotExplorerDetailViewController = segue.destination as? MandelbrotExplorerDetailViewController {
            mandelbrotExplorerDetailViewController.dataController = dataController
            mandelbrotExplorerDetailViewController.defaultMandelbrotEntity = mandelbrotEntity
        }
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let entity = mandelbrotEntity, let image = mandelbrotIUIView.mandelbrotImage else {
            print("mandelbrotEntity = \(String(describing: mandelbrotEntity))")
            print("mandelbrotIUIView.mandelbrotImage = \(String(describing: mandelbrotIUIView.mandelbrotImage))")
            return
        }
        let shareText = "Mandelbrot Set\n\(entity.detailedDescription)"

        let activityItems: [Any] = [shareText, image]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        /*
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.airDrop,
                                                        UIActivity.ActivityType.assignToContact,
                                                        UIActivity.ActivityType.copyToPasteboard,
                                                        UIActivity.ActivityType.mail,
                                                        UIActivity.ActivityType.message,
                                                        UIActivity.ActivityType.openInIBooks,
                                                        UIActivity.ActivityType.print,
                                                        UIActivity.ActivityType.saveToCameraRoll]
        */
        
        present(activityViewController, animated: true, completion: {})
    }
    
}
