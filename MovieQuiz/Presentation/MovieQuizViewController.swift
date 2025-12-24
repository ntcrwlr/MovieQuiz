import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Dependencies
    
    private var alertPresenter = AlertPresenter()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
     setAnswerButtonsEnabled(false)
    }
    
    // MARK: - Actions
    
    @IBAction private func noButton(_ sender: UIButton) {
        presenter.noButtonClicked()
       setAnswerButtonsEnabled(false)
    }
    
    @IBAction private func yesButton(_ sender: UIButton) {
        presenter.yesButtonClicked()
      setAnswerButtonsEnabled(false)
    }
    
    // MARK: - Private Methods: Game Logic
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
        }
  
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
                
                let alert = UIAlertController(
                    title: result.title,
                    message: message,
                    preferredStyle: .alert)
                    
                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.presenter.restartGame()
                }
                
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
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
