//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Дима on 04.04.2024.
//

import Foundation

final class StatisticServiceImplementation: StatisticService{
    var totalAccuracy: Double {
        get{
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let accuracy = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0
            }
            return accuracy
        }
        set{
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    var gamesCount: Int {
        get{
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return count
        }
        set{
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var gamesList: [GameRecord] {
        get{
            guard let data = userDefaults.data(forKey: Keys.gamesList.rawValue),
                  let list = try? JSONDecoder().decode([GameRecord].self, from: data) else {
                return .init()
            }
            return list
        }
        set{
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesList.rawValue)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, gamesList
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGameResults = GameRecord(correct: count, total: amount, date: Date())
        gamesList.append(newGameResults)
        gamesCount += 1
        totalAccuracy = countAccuracyInList(gamesList)
        guard bestGame.compareResults(bestGame) else {
            return
        }
        bestGame = newGameResults
    }
    
    private func countAccuracyInList(_ gamesList: [GameRecord]) -> Double{
        var accuracy: Double = 0
        for element in gamesList{
            let currentAccuracy = Double(element.correct)/Double(element.total) * 100
            accuracy += currentAccuracy
        }
        accuracy = accuracy/Double(gamesList.count)
        return accuracy
    }
}
