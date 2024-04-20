//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Дима on 19.04.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    //Число вопросов в раунде
    let questionsAmount: Int = 10
    
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    //Данные текущего вопроса
    var currentQuestion: QuizQuestion?
    //Счетчик правильных ответов
    var correctAnswers: Int = 0
    //ViewController
    weak var viewController: MovieQuizViewController?
    //Фабрика вопросов
    var questionFactory: QuestionFactoryProtocol?
    //Сервис сбора статистики игр
    var statisticService: StatisticServiceImplementation?
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let question = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return question
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak viewController] in
                viewController?.show(quiz: viewModel)
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            //Сохраняем результат
            statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)
            //Готовим сообщение
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss"
            let formattedDate = dateFormatter.string(from: statisticService.bestGame.date)
            let text = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(formattedDate))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз") { }
            viewController?.alertPresenter.show(quiz: viewModel, identifier: "Game Results")
            self.resetQuestionIndex()
            self.correctAnswers = 0
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
    }
        
    func resetQuestionIndex() {
            currentQuestionIndex = 0
    }
        
    func switchToNextQuestion() {
            currentQuestionIndex += 1
    }
    
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
        viewController?.disableButtons()
    }
}

