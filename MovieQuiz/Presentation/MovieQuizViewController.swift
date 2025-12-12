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
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
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
        setAnswerButtonsEnabled(false)
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            // В случае ошибки не включаем кнопки, пока пользователь не перезапустит загрузку через алерт
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
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
        // Перед запросом следующего вопроса — выключаем кнопки
        setAnswerButtonsEnabled(false)
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
        // Use the designated initializer that matches your implementation
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    
    // MARK: - Private Methods: Game Logic
    
    private func handleAnswer(_ givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Сразу блокируем кнопки, чтобы избежать дабл-кликов
        setAnswerButtonsEnabled(false)
        
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
        if currentQuestionIndex == questionsAmount - 1 {
            finishGame()
        } else {
            currentQuestionIndex += 1
            // Перед запросом следующего вопроса — выключаем кнопки
            setAnswerButtonsEnabled(false)
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func finishGame() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
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
        Ваш результат: \(correctAnswers)/\(questionsAmount)
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
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.reset()
            // Перед новой загрузкой — выключаем кнопки
            self.setAnswerButtonsEnabled(false)
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
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            // Перед перезагрузкой — выключаем кнопки
            self.setAnswerButtonsEnabled(false)
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
    
    // MARK: - Private Methods: Data Conversion
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // MARK: - Private Methods: Buttons State
    
    private func setAnswerButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }
}

