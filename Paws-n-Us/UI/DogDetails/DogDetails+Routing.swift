//
//  DogDetails+Routing.swift
//  Pawsinus
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI

extension DogDetails {
    struct Routing: Equatable {
        var sheetCover: SheetCover?
    }
    
    enum SheetCover: Identifiable, Equatable {
        case report(Dog)
        
        var id: String {
            switch self {
            case .report(let dog):
                return "report_\(dog.id)"
            }
        }
    }
}