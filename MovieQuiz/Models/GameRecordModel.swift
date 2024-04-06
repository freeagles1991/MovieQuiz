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
    
    func compareResults(_ previousGameRecord: GameRecord) -> Bool{
        correct > previousGameRecord.correct
    }

}
