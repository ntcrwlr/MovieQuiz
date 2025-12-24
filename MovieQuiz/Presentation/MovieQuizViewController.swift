import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
   // private let presenter = MovieQuizPresenter!
    
    // MARK: - Dependencies
    
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
       // presenter.viewController = self
       // setupQuestionFactory()
        imageView.layer.cornerRadius = 20
        statisticService = StatisticService()

        showLoadingIndicator()
     setAnswerButtonsEnabled(false) // закомментировано по просьбе
       // questionFactory?.loadData()
    }
    
    
/*
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
        setAnswerButtonsEnabled(true)
        resetImageBorder()
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
*/
    
    
    // MARK: - Actions
    
    @IBAction private func noButton(_ sender: UIButton) {
        presenter.noButtonClicked()
       setAnswerButtonsEnabled(false)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        presenter.yesButtonClicked()
      setAnswerButtonsEnabled(false)
    }
    
    // MARK: - Private Methods: Setup
    
  //  private func setupQuestionFactory() {
  //      questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
 //   }
    
    // MARK: - Private Methods: Game Logic
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        imageView.layer.cornerRadius = 20
        
        // Кнопки остаются выключенными до загрузки следующего вопроса
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self else { return }
                        self.presenter.showNextQuestionOrResults()
                
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            finishGame()
        } else {
            presenter.switchToNextQuestion()
            setAnswerButtonsEnabled(false) // закомментировано по просьбе
            self.presenter.restartGame()
        }
    }
    
    private func finishGame() {
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
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
        Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
        Количество сыгранных квизов: \(gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(accuracy)%
        """
        
        return resultMessage
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let model = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            // Сброс и запуск нового раунда
            self.presenter.resetQuestionIndex()
            // self.questionFactory?.reset()
          self.setAnswerButtonsEnabled(false) // закомментировано по просьбе
           // self.questionFactory?.requestNextQuestion()
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        // activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
            
            self.showLoadingIndicator()
            self.setAnswerButtonsEnabled(false) // закомментировано по просьбе
            // self.questionFactory?.loadData()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // MARK: - Private Methods: UI Updates
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        countLabel.text = step.questionNumber
    }
    
    func resetImageBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - Private Methods: Buttons State
    
   func setAnswerButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        yesButton.alpha = isEnabled ? 1.0 : 0.5
        noButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
}
