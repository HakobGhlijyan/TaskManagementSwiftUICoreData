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
        // Инициализация запроса с помощью NSPredicate
        // Intializing Request With NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: nil)
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                ContentUnavailableView("No Task found!!!", systemImage: "list.bullet.clipboard", description: Text("Add your task for visible in list per hour"))
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}
