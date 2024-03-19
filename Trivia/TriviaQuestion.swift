//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

struct TriviaQuestion {
  let category: String
  let question: String
  let correctAnswer: String
  let incorrectAnswers: [String]
}


class TriviaQuestionService {
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var allQuestions: [TriviaQuestion] = []
        
        dispatchGroup.enter()
        fetchQuestionsOfType(type: "multiple", amount: 10) { questions in
            allQuestions.append(contentsOf: questions ?? [])
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchQuestionsOfType(type: "boolean", amount: 5) { questions in
            allQuestions.append(contentsOf: questions ?? [])
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(allQuestions.shuffled())
        }
    }
    
    private func fetchQuestionsOfType(type: String, amount: Int, completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=\(amount)&type=\(type)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData 

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let questions = decodedData.results.map { result -> TriviaQuestion in
                    return TriviaQuestion(
                        category: result.category,
                        question: result.question,
                        correctAnswer: result.correct_answer,
                        incorrectAnswers: result.incorrect_answers
                    )
                }
                completion(questions)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}




struct TriviaResponse: Codable {
    let results: [QuestionData]
}

struct QuestionData: Codable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
