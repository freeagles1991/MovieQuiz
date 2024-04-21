//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Дима on 28.03.2024.
//

import Foundation
import UIKit


protocol AlertPresenterDelegate: UIViewController {
    func didResultsWasShown()
}
// приватный метод для показа результатов раунда квиза
// принимает вью модель QuizResultsViewModel и ничего не возвращает
final class AlertPresenter{
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func show(quiz result: AlertModel, identifier: String) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = identifier
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didResultsWasShown()
        }
        
        alert.addAction(action)

        delegate?.present(alert, animated: true, completion: nil)
    }
}


