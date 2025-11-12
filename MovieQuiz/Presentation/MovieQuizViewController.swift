import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var картинка: UIImageView!
    @IBOutlet private weak var счетчик: UILabel!
    @IBOutlet private weak var вопрос: UILabel!

    private struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }

    private struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }


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

    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
    }


    @IBAction private func Нет(_ sender: UIButton) {
        handleAnswer(false)
    }

    @IBAction private func Да(_ sender: UIButton) {
        handleAnswer(true)
    }

    private func handleAnswer(_ givenAnswer: Bool) {
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }


    private func showCurrentQuestion() {
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
        resetImageBorder()
    }

    private func show(quiz step: QuizStepViewModel) {
        картинка.image = step.image
        вопрос.text = step.question
        счетчик.text = step.questionNumber
    }

    private func resetImageBorder() {
        картинка.layer.masksToBounds = true
        картинка.layer.borderWidth = 0
        картинка.layer.cornerRadius = 20
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        картинка.layer.masksToBounds = true
        картинка.layer.borderWidth = 8
        картинка.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        картинка.layer.cornerRadius = 20

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }

    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showCurrentQuestion()
        }

        alert.addAction(action)

        present(alert, animated: true)
    }


    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
}

