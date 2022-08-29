//
//  ShareActivityView.swift
//  SearchPubChem
//
//  Created by Jae Seung Lee on 10/8/21.
//  Copyright © 2021 Jae Seung Lee. All rights reserved.
//

import SwiftUI

struct ShareActivityView: UIViewControllerRepresentable {
    let image: UIImage
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: applicationActivities)

        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.assignToContact,
                                                        UIActivity.ActivityType.openInIBooks]
        
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }

}
