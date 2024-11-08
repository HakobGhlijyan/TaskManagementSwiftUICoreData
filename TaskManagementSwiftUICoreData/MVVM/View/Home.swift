//
//  Home.swift
//  TaskManagementSwiftUI
//
//  Created by Hakob Ghlijyan on 06.11.2024.
//

import SwiftUI
import CoreData

struct Home: View {
    @StateObject private var viewModel: TaskViewModel = TaskViewModel()
    @Namespace private var namespaceAnimation
    @Environment(\.colorScheme) private var colorScheme
    
    //MARK: - CoreData Context
    @Environment(\.managedObjectContext) private var context
    //MARK: - CoreData Context for edit button
    @Environment(\.editMode) private var editButton
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(
                spacing: 20,
                pinnedViews: [.sectionHeaders]) {
                    Section {
                        //MARK: - Current week
                        ScrollView(.horizontal, showsIndicators: false) {
                            //MARK: - DATE
                            HStack(spacing: 10.0) {
                                ForEach(viewModel.currentWeek, id: \.self) { day in
                                    VStack(spacing: 10.0) {
                                        Text(viewModel.extractDate(date: day, format: "dd"))
                                            .font(.system(size: 15))
                                            .fontWeight(.semibold)
                                        // EEE Return day In MON format
                                        Text(viewModel.extractDate(date: day, format: "EEE"))
                                            .font(.system(size: 14))
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 8, height: 8)
                                            .opacity(viewModel.isToday(date: day) ? 1 : 0)
                                    }
                                    .foregroundStyle(viewModel.isToday(date: day) ? .primary : .secondary)
                                    .foregroundColor(viewModel.isToday(date: day) ? .white : .black)
                                    .frame(width: 45, height: 90)
                                    .background(
                                        ZStack {
                                            //MARK: - match geometry effect
                                            if viewModel.isToday(date: day) {
                                                Capsule()
                                                    .fill(.black)
                                                    .matchedGeometryEffect(id: "current_day", in: namespaceAnimation)
                                            }
                                        }
                                    )
                                    .contentShape(Capsule())
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.currentDay = day
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            //MARK: - TASKS
                            TaskView()
                        }
                    } header: {
                        HeaderView()
                    }
                }
        }
        .ignoresSafeArea(.container, edges: .top)
        //MARK: - Add Button
        .overlay (
            Button {
                viewModel.addNewTask.toggle()
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.primary, in: Circle())
            }
            .padding()
            
            , alignment: .bottomTrailing
        )
        .sheet(isPresented: $viewModel.addNewTask) {
            // clear edit data
            viewModel.editTask = nil
        } content: {
            NewTaskView()
                .environmentObject(viewModel)
        }
//IZMENIM SHHET NA TO CHOT ON POLUSHIT VIEWMODEL I V NEM BUDET LOGIC DLYA EDIT I ADD VARIANTOV

    }
    
    //MARK: - Header View
    @ViewBuilder func HeaderView() -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10.0) {
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                Text("Today").font(.largeTitle).bold()
            }
            .hLeading()
            .foregroundStyle(.primary)
            
            //MARK: - Edit Button
            EditButton()
        }
        .padding()
        .padding(.top, getSafeArea().top)
        .background(colorScheme == .light ? .white : .black)
    }
    
    //MARK: - Task view
    @ViewBuilder func TaskView() -> some View {
        LazyVStack(spacing: 18) {
            //MARK: - Converting object as our Task Model
            //MARK: - Преобразование объекта в качестве модели нашей задачиConverting object as our Task Model
            DynamicFilteredView(dateToFilter: viewModel.currentDay) { (object:Task) in
                TaskCardView(task: object)
            }
        }
        .padding()
        .padding(.top)
    }

    //MARK: - Task Card View
    @ViewBuilder func TaskCardView(task: Task) -> some View {
        HStack(alignment: editButton?.wrappedValue == .active ? .center : .top, spacing: 30.0) {
            
            //1 if edit mode enable then showing delet button
            if editButton?.wrappedValue == .active {
                // edit button for current and future tasks
                VStack(spacing: 10) {
                    
                    //1. Esli task date compare (Сравнивает другую дату с этой.) -> ordered (Левый операнд больше правого.) -> i esli eto current data v task e , a esli on mennche to pencil nebudet
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                        Button {
                            viewModel.editTask = task
                            viewModel.addNewTask.toggle()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    Button {
                        //MARK: - Deleting Task
                        withAnimation {
                            //delete
                            context.delete(task)
                            //save
                            try? context.save()
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }

                }
            } else {
                VStack(spacing: 10.0) {
                    Circle()
                        .fill(viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? (task.isCompleted ? .green : .black) : .clear)
                        .frame(width: 15, height: 15)
                        .background(
                            Circle()
                                .stroke(.black, lineWidth: 1)
                                .padding(-3)
                        )
                        .scaleEffect(!viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1 )
                    
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 3)
                }
            }
            
            //2
            VStack {
                //1
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.taskTitle ?? "")
                            .font(.headline.bold())
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                }
                
                //2
                if viewModel.isCurrentHour(date: task.taskDate ?? Date()) {
                    //MARK: - Team Members
                    HStack(spacing: 12) {
                        
//                        HStack(spacing: -10) {
//                            ForEach(viewModel.userImage, id: \.self) { user in
//                                Image(user)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 40, height: 40)
//                                    .clipShape(Circle())
//                                    .background(
//                                        Circle().stroke(.black, lineWidth: 5)
//                                    )
//                            }
//                        }
//                        .hLeading()
                        
                        //MARK: - Check Button
                        if !task.isCompleted {
                            Button {
                                //MARK: - Updating Task
                                withAnimation {
                                    //updating status
                                    task.isCompleted = true
                                    //save
                                    try? context.save()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.white, in: Circle())
                            }
                        }
                        
                        Text(task.isCompleted ? "Marked as Completed" : "Mark Task as Completed")
                            .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                            .foregroundStyle(task.isCompleted  ? . gray : .white)
                            .hLeading()
                        
                    }
                    .padding(.top, 4)
                }
                
            }
            .foregroundStyle(viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .primary)
            .padding(viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 0)
            .padding(.bottom, viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("AppBlack")
                    .clipShape(.rect(cornerRadius: 20))
                    .opacity(viewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
            
        }
        .hLeading()
    }
    
}

#Preview {
    Home()
}


//MARK: - UI design Helper function
extension View {
    // ALIGNMENT
    func hLeading() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }
    
    //SAFE AREA
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        guard let safeArea = screen.windows.first?.safeAreaInsets else { return .zero }
        return safeArea
    }
}
