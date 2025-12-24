//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 23.12.2025.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
    func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
    func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
            }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
            }
    
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = isYes
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
   
    func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!" // ОШИБКА 1: `correctAnswers` не определено
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion() // ОШИБКА 3: `questionFactory` не определено
            }
        }
        
}
