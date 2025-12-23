import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Dependencies
    
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQuestionFactory()
        imageView.layer.cornerRadius = 20
        statisticService = StatisticService()

        showLoadingIndicator()
        setAnswerButtonsEnabled(false) // закомментировано по просьбе
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            // В случае ошибки не включаем кнопки, пока пользователь не перезапустит загрузку через алерт
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.show(quiz: viewModel)
            self.resetImageBorder()
            // После отображения свежих данных — включаем кнопки
            self.setAnswerButtonsEnabled(true)
        }
    }
    
    func didLoadDataFromServer() {
        // Data loaded successfully; hide spinner and request the first question
        hideLoadingIndicator()
        questionFactory?.reset()
        setAnswerButtonsEnabled(false) // закомментировано по просьбе
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        // Show error alert and allow retry
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButton(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        handleAnswer(true)
    }
    
    // MARK: - Private Methods: Setup
    
    private func setupQuestionFactory() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    
    // MARK: - Private Methods: Game Logic
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Сразу блокируем кнопки, чтобы избежать дабл-кликов
        setAnswerButtonsEnabled(false) // закомментировано по просьбе
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        imageView.layer.cornerRadius = 20
        
        // Кнопки остаются выключенными до загрузки следующего вопроса
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            finishGame()
        } else {
            presenter.switchToNextQuestion()
            setAnswerButtonsEnabled(false) // закомментировано по просьбе
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func finishGame() {
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let text = makeResultsMessage()
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз"
        )
        show(quiz: viewModel)
    }
    
    private func makeResultsMessage() -> String {
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        let gamesCount = statisticService.gamesCount
        
        let resultMessage = """
        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(accuracy)%
        """
        
        return resultMessage
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            // Сброс и запуск нового раунда
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.reset()
            self.setAnswerButtonsEnabled(false) // закомментировано по просьбе
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            self.setAnswerButtonsEnabled(false) // закомментировано по просьбе
            self.questionFactory?.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - Private Methods: UI Updates
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        countLabel.text = step.questionNumber
    }
    
    private func resetImageBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - Private Methods: Buttons State
    
    private func setAnswerButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }
}
