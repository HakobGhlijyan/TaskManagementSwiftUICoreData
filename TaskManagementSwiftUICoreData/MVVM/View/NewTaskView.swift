//
//  NewTaskView.swift
//  TaskManagementSwiftUICoreData
//
//  Created by Hakob Ghlijyan on 08.11.2024.
//

import SwiftUI
import CoreData

struct NewTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - CoreData Context
    @Environment(\.managedObjectContext) private var context
    
    //MARK: - Task Value
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Go to ....", text: $taskTitle)
                } header: {
                    Text("Task Title")
                }
                Section {
                    TextField("Description your task here", text: $taskDescription)
                } header: {
                    Text("Task Description")
                }
                Section {
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.graphical)
                } header: {
                    Text("Task Date")
                }

            }
            .navigationTitle("Add new Task")
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let task = Task(context: context)
                        task.taskTitle = taskTitle
                        task.taskDescription = taskDescription
                        task.taskDate = taskDate
                        
                        //save task in
                       do {
                           try context.save()
                       } catch {
                           print("DEBUG: - Error Saving: \(error.localizedDescription)")
                       }
                        //close view
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(taskTitle == "" || taskDescription == "")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent).accentColor(.red)
                }
                
            }
        }
    }
}

#Preview {
    NewTaskView()
}
