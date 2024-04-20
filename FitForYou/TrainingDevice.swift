//
//  TrainingDevice.swift
//  TrainingDevice
//
//  Created by Markus B. on 29.03.24.
//

import Foundation

struct TrainingDevice: Codable{
    var bezeichnung: String
    var nummer: String
    var einstellung: String
    var gewicht: String
    var kommentar: Optional<String>
    var kategorie: Optional<Int>

    var description: String {
        return "Einstellung: \(einstellung) Gewicht: \(gewicht)"
    }
}
