//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Дима on 16.04.2024.
//

import XCTest // не забывайте импортировать фреймворк для тестирования
@testable import MovieQuiz // импортируем приложение для тестирования

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // сравниваем данные с тем, что мы предполагали
                expectation.fulfill()
            case .failure(_):
                // мы не ожидаем, что пришла ошибка; если она появится, надо будет провалить тест
                XCTFail("Unexpected failure") // эта функция проваливает тест
            }
        }
       
       waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        // так как функция загрузки фильмов — асинхронная, нужно ожидание
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                // сравниваем данные с тем, что мы предполагали
                XCTFail("Unexpected failure") // эта функция проваливает тест
            case .failure(let error):
                // мы ожидаем, что пришла ошибка; если она появится, тест пройден
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
       
       waitForExpectations(timeout: 1)
        
    }
}
