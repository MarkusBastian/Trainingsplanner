//
//  TrainingsDeviceInCategory.swift
//  FitForYou
//
//  Created by Markus B. on 23.04.24.
//

import Foundation

struct TrainingDeviceInCategory: Codable {
    var category: Int
    var categoryTitle: Optional<String>
    var trainingDevices: [TrainingDevice]

    var description: String {
        return "Kategory: \(category)"
    }
}
