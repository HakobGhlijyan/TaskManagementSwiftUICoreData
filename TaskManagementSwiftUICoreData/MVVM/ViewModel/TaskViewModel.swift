//
//  TaskViewModel.swift
//  TaskManagementSwiftUI
//
//  Created by Hakob Ghlijyan on 07.11.2024.
//

import SwiftUI
import CoreData

final class TaskViewModel: ObservableObject {
    
    @Published var userImage = ["User1","User2","User3","User4","User5"]
    //MARK: - Current Week Day
    @Published var currentWeek: [Date] = []
    //MARK: - Current Day
    @Published var currentDay: Date = Date()
    //MARK: - Filtered Today Task
    @Published var filteredTask: [Task]?
    //MARK: - New Task View
    @Published var addNewTask: Bool = false
    
    
    //MARK: - Init
    init() {
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        let today = Date()                      //today is current day
        let calendar = Calendar.current         //calendar is current week
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today )   // is current week is current day
        
        guard let firstWeekDay = week?.start else { return }    //first day , is start day
        
        (1...7).forEach { day in      // for each in array for append day is calendar
            if let weekDay = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekDay)
            }
        }
    }
    
    //MARK: - Extract date info
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //MARK: - Cheking current day
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    //MARK: - Checking if the current task hour
    func isCurrentHour(date: Date) -> Bool {
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        return hour == currentHour
    }
    
}
