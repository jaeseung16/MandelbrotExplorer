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
    
    var body: some View {
        VStack {
            Text("\(maxImaginary)")
                .font(.caption)
                .foregroundColor(.black)
            
            HStack {
                Text("\(minReal)")
                    .font(.caption)
                    .foregroundColor(.black)
                    .rotationEffect(Angle(degrees: -90.0))
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                Text("\(maxReal)")
                    .font(.caption)
                    .foregroundColor(.black)
                    .rotationEffect(Angle(degrees: -90.0))
            }
            
            Text("\(minImaginary)")
                .font(.caption)
                .foregroundColor(.black)
            
            HStack {
                Spacer()
                Text("max iteration: \(maxIter)\ncreated on ") + Text(created, format: Date.FormatStyle(date: .numeric, time: .omitted))
            }
            .font(.caption)
            .foregroundColor(.black)
        }
        .background(Color.white)
        .frame(width: 400, height: 400)
    }
}

