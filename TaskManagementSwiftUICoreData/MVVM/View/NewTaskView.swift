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
    
    //MARK: - CoreData Context
    @EnvironmentObject private var viewModel: TaskViewModel
    
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
                //Disabled date for edit mode               
                if viewModel.editTask == nil {
                    Section {
                        DatePicker("", selection: $taskDate)
                            .datePickerStyle(.graphical)
                    } header: {
                        Text("Task Date")
                    }
                }

            }
            .navigationTitle("Add new Task")
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let task = viewModel.editTask {
                            task.taskTitle = taskTitle
                            task.taskDescription = taskDescription
                        } else {
                            let task = Task(context: context)
                            task.taskTitle = taskTitle
                            task.taskDescription = taskDescription
                            task.taskDate = taskDate
                        }
                        //save task in
                       do {
                           try context.save()
                       } catch {
                           print("DEBUG: - Error Saving: \(error.localizedDescription)")
                       }
                        //close view
                        dismiss()
                    }
                    .disabled(taskTitle == "" || taskDescription == "")
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
            //Loading data is Task from edit mode
            .onAppear {
                if let task = viewModel.editTask {
                    taskTitle = task.taskTitle ?? ""
                    taskDescription = task.taskDescription ?? ""
                }
            }
        }
    }
}

#Preview {
    NewTaskView()
}
