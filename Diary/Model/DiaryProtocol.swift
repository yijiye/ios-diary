//
//  DiaryProtocol.swift
//  Diary
//
//  Created by 리지, Goat on 2023/05/02.
//

import Foundation

protocol DiaryProtocol {
    var id: UUID { get set }
    var title: String { get set }
    var body: String { get set }
    var createdDate: Double { get set }
    var weatherState: String? { get set }
    var icon: String? { get set }
}
