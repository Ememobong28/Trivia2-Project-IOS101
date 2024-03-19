//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

extension String {
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let decodedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil).string else {
            return self
        }
        
        return decodedString
    }
}


class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    // TODO: FETCH TRIVIA QUESTIONS HERE
    fetchTriviaQuestions()
  }
    
    private func fetchTriviaQuestions() {
        TriviaQuestionService().fetchTriviaQuestions { [weak self] questions in
            DispatchQueue.main.async {
                guard let questions = questions else { return }
                self?.questions = questions
                self?.updateQuestion(withQuestionIndex: self?.currQuestionIndex ?? 0)
            }
        }
    }
  
    
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        
        questionLabel.text = question.question.decodingHTMLEntities()
        categoryLabel.text = question.category
        
        let isTrueFalseQuestion = question.incorrectAnswers.count == 1
        
        let correctAnswer = question.correctAnswer.decodingHTMLEntities()
        let incorrectAnswer = question.incorrectAnswers.first?.decodingHTMLEntities() ?? "N/A"
        
        answerButton0.setTitle(correctAnswer, for: .normal)
        answerButton1.setTitle(incorrectAnswer, for: .normal)
        
        if isTrueFalseQuestion {
            answerButton2.isHidden = true
            answerButton3.isHidden = true
        } else {
            let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled().map { $0.decodingHTMLEntities() }
            answerButton0.setTitle(answers[0], for: .normal)
            answerButton1.setTitle(answers[1], for: .normal)
            answerButton2.setTitle(answers[2], for: .normal)
            answerButton3.setTitle(answers[3], for: .normal)
            answerButton2.isHidden = false
            answerButton3.isHidden = false
        }
    }

   
    private func updateToNextQuestion(answer: String, sender: UIButton) {
        let correct = isCorrectAnswer(answer)
        
        sender.backgroundColor = correct ? .green : .red
        
        if correct {
            numCorrectQuestions += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.resetButtonColors()
            
            self?.currQuestionIndex += 1
            guard self?.currQuestionIndex ?? 0 < self?.questions.count ?? 0 else {
                self?.showFinalScore()
                return
            }
            self?.updateQuestion(withQuestionIndex: self?.currQuestionIndex ?? 0)
        }
    }

    private func resetButtonColors() {
        answerButton0.backgroundColor = .clear
        answerButton1.backgroundColor = .clear
        answerButton2.backgroundColor = .clear
        answerButton3.backgroundColor = .clear
    }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
      currQuestionIndex = 0
      numCorrectQuestions = 0
      
      self.questions.removeAll()
      fetchTriviaQuestions()

    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
    
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "", sender: sender)
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "" , sender: sender)
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "" , sender: sender)
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "" , sender: sender)
  }
}

