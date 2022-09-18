//
//  ShareView.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 8/29/22.
//  Copyright © 2022 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct ShareView: View {
    
    let minReal: Double
    let maxReal: Double
    let minImaginary: Double
    let maxImaginary: Double
    let maxIter: Int
    let created: Date
    let uiImage: UIImage
    
    private let fontColor = Color.white
    private let backgroundColor = Color.black
    
    var body: some View {
        VStack(spacing: 0.0) {
            detailView
                .scaledToFill()
            
            HStack {
                Spacer()
                Text("max iteration: \(maxIter)\ncreated on ") + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted))
            }
            .font(.caption)
            .foregroundColor(fontColor)
            .padding()
        }
        .background(backgroundColor)
    }
    
    private var detailView: some View {
        VStack {
            Text("\(maxImaginary)")
                .font(.caption)
                .foregroundColor(fontColor)
                .offset(x: 0.0, y: 10.0)
            
            HStack {
                Text("\(minReal)")
                    .font(.caption)
                    .foregroundColor(fontColor)
                    .rotationEffect(Angle(degrees: -90.0))
                    .offset(x: 30.0, y: 0.0)
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .border(Color.white, width: 1.0)
                
                Text("\(maxReal)")
                    .font(.caption)
                    .foregroundColor(fontColor)
                    .rotationEffect(Angle(degrees: -90.0))
                    .offset(x: -30.0, y: 0.0)
            }
            
            Text("\(minImaginary)")
                .font(.caption)
                .foregroundColor(fontColor)
                .offset(x: 0.0, y: -5.0)
        }
    }
}

