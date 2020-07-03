# MandelbrotExplorer

## Description

Based on the experince with [jaeseung16/CppND-Capstone-MandelbrotExplorer](https://github.com/jaeseung16/CppND-Capstone-MandelbrotExplorer), I wanted to see how the implementation could be different between Swift/MetalKit and C++/OpenCV.

## Project Structure

- ViewController
- MandelbrotView: Presents images and ranges
- MandelbrotDisplay: Generates an image to present, with a given ranges of complex numbers
- MnadelbrotSet: Evaluates the Mandelbrot formula for a list of complex numbers

## Requirements

- Xcode


## How to build

- Download or clone the repository: git clone https://github.com/jaeseung16/CppND-Capstone-MandelbrotExplorer.git
- Build the project within Xcode


### References

Web sites/pages I encountered while working on the project:

#### Mandelbrot

- [bilics/mandelbrot_iosmetal](https://github.com/bilics/mandelbrot_iosmetal/blob/master/mandelbrot_metal/Mandelbrot.swift)

#### Drawing

- [Drawing Images From Pixel Data - In Swift](https://blog.human-friendly.com/drawing-images-from-pixel-data-in-swift)

#### Metal

- [3D Graphics with Metal @ raywenderlich.com](https://www.raywenderlich.com/1258241-3d-graphics-with-metal)
- [github.com/atveit/SwiftMetalGPUParallelProcessing](https://github.com/atveit/SwiftMetalGPUParallelProcessing/blob/master/SwiftMetalProcessing/ViewController.swift)
- [MetalKit/metal](https://github.com/MetalKit/metal/blob/master/raytracing/Shaders.metal)

#### Etc.
- [Parallel For-Loop in Swift: DispatchQueue concurrentPerform](https://touren.github.io/2019/02/22/ConcurrentPerform_In_Swift.html)
