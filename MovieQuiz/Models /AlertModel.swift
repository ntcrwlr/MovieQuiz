//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 30.11.2025.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
