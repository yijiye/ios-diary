//
//  MyDiary.swift
//  Diary
//
//  Created by 리지, Goat on 2023/05/02.
//

import Foundation

struct MyDiary: DiaryProtocol {
    var id: UUID
    var title: String
    var body: String
    var createdDate: Double
    var weatherState: String?
    var icon: String?
}
