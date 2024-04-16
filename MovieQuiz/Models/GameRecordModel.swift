//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Дима on 04.04.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func compareResults(newGameResult: GameRecord, previousGameRecord: GameRecord) -> Bool{
        newGameResult.correct > previousGameRecord.correct
    }

}
