//
//  Untitled.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 24.12.2025.
//

import UIKit
import Foundation


protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func resetImageBorder()
    func setAnswerButtonsEnabled(_ isEnabled: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

