//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Дима on 23.03.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)   
}
