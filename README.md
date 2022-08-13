# MandelbrotExplorer


[![App Store Badge](https://linkmaker.itunes.apple.com/assets/shared/badges/en-us/appstore-lrg.svg)](https://apps.apple.com/us/app/mandelbrot-navigator/id1539536674)

## Description

The app provides with a set of options to navigate through the [Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set) in iPad. Starting from the initial range, you can zoom into a selected range and choose the color scheme and the maximum iterations. If you like the finding, you can save it for the furtuer navigation and/or share it.


## How to Use

- The app is designed to use in iPad with the landscape orientation.
- After opening the app, choose an item under on the left pane.
  - The Mandelbrot set within the saved region will show up with the information about the region and the maximum iteration.
  - The bar items will be enabled.
- Click **Explore** to open a scene to navigate down the chosen region.
  - The Mandelbrot set within the saved region is presented in the bottom-right image.
  - The bottom-right image also has a white box, which can be dragged and pinched. 
  - While being dragged or pinched, the color of the box becomes yellow.
  - When released, the color of the box becomes white and the top-left image will be updated.
  - Try different color scheme and maximum iteration and click **Refresh** to update the top-left image.
  - If you like the result, you may save it. Or you can go back to the original state by clicking **Reset**.
  - **Cannot explore further** will appear if the range is too small to navigate. This is because the single precision is used to represent numbers in a GPU.


## Requirements

- The app is written and tested on `Xcode 12.2` and `Swift 5.3.1`.


## How to build

- Download or clone the repository: `git clone https://github.com/jaeseung16/CppND-Capstone-MandelbrotExplorer.git`
- Build the project within Xcode


## Motivation

Based on the experince with [jaeseung16/CppND-Capstone-MandelbrotExplorer](https://github.com/jaeseung16/CppND-Capstone-MandelbrotExplorer), I wanted to see how the implementation could be different between Swift/MetalKit and C++/OpenCV.

### References

Web sites/pages I encountered while working on the project:

- Mandelbrot
  - [bilics/mandelbrot_iosmetal](https://github.com/bilics/mandelbrot_iosmetal/blob/master/mandelbrot_metal/Mandelbrot.swift)
- Drawing
  - [Drawing Images From Pixel Data - In Swift](https://blog.human-friendly.com/drawing-images-from-pixel-data-in-swift)
- Metal
  - [3D Graphics with Metal @ raywenderlich.com](https://www.raywenderlich.com/1258241-3d-graphics-with-metal)
  - [github.com/atveit/SwiftMetalGPUParallelProcessing](https://github.com/atveit/SwiftMetalGPUParallelProcessing/blob/master/SwiftMetalProcessing/ViewController.swift)
  - [MetalKit/metal](https://github.com/MetalKit/metal/blob/master/raytracing/Shaders.metal)
- etc.
  - [Parallel For-Loop in Swift: DispatchQueue concurrentPerform](https://touren.github.io/2019/02/22/ConcurrentPerform_In_Swift.html)
