//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Дима on 19.04.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
//Число вопросов в раунде
    private let questionsAmount: Int = 10
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex: Int = 0
    //Данные текущего вопроса
    private var currentQuestion: QuizQuestion?
    //Счетчик правильных ответов
    private var correctAnswers: Int = 0
    //ViewController
    private weak var viewController: MovieQuizViewController?
    //Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    //Сервис сбора статистики игр
    private var statisticService: StatisticService!
    //Сервис показа алертов
    private var alertPresenter: AlertPresenter?
    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            alertPresenter = AlertPresenter(delegate: viewController)
            statisticService = StatisticServiceImplementation()
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
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
        DispatchQueue.main.async { [weak self ] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // показывает результат ответа на вопрос
    private func proceedWithAnswer(isCorrectAnswer: Bool) {
        didAnswer(isCorrectAnswer: isCorrectAnswer)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer)
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func makeResultsMessage() -> String {
        guard let statisticService = statisticService else { return "" }
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
        return text
    }
    
    //Показывает ошибку сети
    private func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.restartGame()
        }
        
        alertPresenter?.show(quiz: model, identifier: "Network error")
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: makeResultsMessage(),
                buttonText: "Сыграть ещё раз") { }
            alertPresenter?.show(quiz: viewModel, identifier: "Game Results")
            self.restartGame()
            self.correctAnswers = 0
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
        
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // MARK: - Кнопки ДА и Нет
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
            
        proceedWithAnswer(isCorrectAnswer: givenAnswer == currentQuestion.correctAnswer)
        viewController?.disableButtons()
    }
    
    private func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer{
            correctAnswers += 1
        }
    }
}

