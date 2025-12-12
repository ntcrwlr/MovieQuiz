//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 24.11.2025.
//
import UIKit
import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    private var movies: [MostPopularMovie] = []
    private var usedQuestionIndices: Set<Int> = []

    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            guard !self.movies.isEmpty else {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }

            let index = (0..<self.movies.count).randomElement() ?? 0

            guard index >= 0 && index < self.movies.count else {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }

            let movie = self.movies[index]

            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                // Можно передать nil вопрос, чтобы UI показал ошибку/ретрай
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }

            // Генерация разного вопроса под конкретный фильм
            let (text, correctAnswer) = self.makeQuestion(for: movie)

            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer
            )

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func reset() {
        usedQuestionIndices.removeAll()
    }
}

// MARK: - Вспомогательная генерация вопросов
private extension QuestionFactory {
    enum QuestionType: CaseIterable {
        case ratingMoreThan7
        case ratingLessThan5
        case ratingMoreThan9
    }
    
    func makeQuestion(for movie: MostPopularMovie) -> (text: String, correct: Bool) {
        let type = QuestionType.allCases.randomElement() ?? .ratingMoreThan7
        
        let ratingValue = Float(movie.rating) ?? 0
        let title = movie.title
        
        switch type {
        case .ratingMoreThan7:
            // Классический вопрос
            return ("Рейтинг этого фильма больше чем 7?", ratingValue > 7.0)
        case .ratingLessThan5:
            return ("Рейтинг этого фильма меньше чем 5?", ratingValue < 5.0)
        case .ratingMoreThan9:
            return ("Рейтинг этого фильма меньше чем 9?", ratingValue > 9.0)
        }
    }
}
