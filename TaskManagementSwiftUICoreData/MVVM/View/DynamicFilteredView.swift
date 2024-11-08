//
//  DynamicFilteredView.swift
//  TaskManagementSwiftUICoreData
//
//  Created by Hakob Ghlijyan on 07.11.2024.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content:View, T>: View where T: NSManagedObject {
    //MARK: - CoreDate request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    //MARK: - Building Custom ForEach which will give Coredata object to build View,
    //MARK: - Создание пользовательского ForEach, который предоставит объект Coredata для построения представления
    init(dateToFilter: Date, @ViewBuilder content: @escaping (T) -> Content) {
        //MARK: - Predicate to filter current date Task
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        //Filter key
        let filterKey = "taskDate"  // filter po date v baze coredata
        
        // This will fetch task between today and tommorow which is 24 HRS
        // Это приведет к получению задания в период с сегодняшнего по завтрашний день, то есть через 24 часа
        let predicate = NSPredicate(
            format: "\(filterKey) >= %@ AND \(filterKey) < %@",
            argumentArray: [today, tomorrow]
        )
        
        // Инициализация запроса с помощью NSPredicate
        // Intializing Request With NSPredicate
        // Add sort Descriptors
        _request = FetchRequest(
            entity: T.entity(),
            sortDescriptors: [.init(keyPath: \Task.taskDate, ascending: true)],
            predicate: predicate
        )
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                ContentUnavailableView(
                    "No Task found!!!",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Add your task for visible in list per hour")
                )
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}
