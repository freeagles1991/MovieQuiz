//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Дима on 28.03.2024.
//

import Foundation
import UIKit

// приватный метод для показа результатов раунда квиза
// принимает вью модель QuizResultsViewModel и ничего не возвращает
final class AlertPresenter{
    weak var delegate: MovieQuizViewController?
    
    init(delegate: MovieQuizViewController? = nil) {
        self.delegate = delegate
    }
    
    func show(quiz result: AlertModel, alert: UIAlertController) {
        alert.title = result.title
        alert.message = result.message
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didResultsWasShown()
        }

        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}


