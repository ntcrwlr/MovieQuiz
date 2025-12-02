//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 24.11.2025.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    private var usedQuestionIndices: Set<Int> = []
    
    func setup(delegate: QuestionFactoryDelegate) {
           self.delegate = delegate
       }
    
    func requestNextQuestion() {
        let availableIndices = questions.indices.filter { !usedQuestionIndices.contains($0) }
        
        guard let index = availableIndices.randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        usedQuestionIndices.insert(index)
        
        let question = questions[index]
        delegate?.didReceiveNextQuestion(question: question)
    }
    
    func reset() {
        usedQuestionIndices.removeAll()
    }
}


