//
//  ContentView.swift
//  SwiftData_Bognalbal
//
//  Created by STUDENT on 10/9/25.
//

import SwiftUI

// MARK: - Task Model
struct Task: Identifiable {
    let id = UUID()
    var title: String
    var date: Date
    var priority: Int
    var status: String
    var category: String
}

// MARK: - Main View
struct TodoAppView: View {
    @State private var tasks: [Task] = [
        Task(title: "Watch a movie", date: Date(), priority: 1, status: "TODO", category: "Personal"),
        Task(title: "Go to Mosque", date: Date().addingTimeInterval(-86400), priority: 2, status: "TODO", category: "Religion"),
        Task(title: "Sleep", date: Date(), priority: 3, status: "DONE", category: "Health")
    ]
    
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedPriority: Int = 0
    @State private var showAddTask = false

    let categories = ["All", "Work", "Personal", "Health", "Religion", "School"]

    // MARK: - Filter Logic
    var filteredTasks: [Task] {
        tasks.filter { task in
            (searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == "All" || task.category == selectedCategory) &&
            (selectedPriority == 0 || task.priority == selectedPriority)
        }
    }

    // MARK: - UI
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    // Title + Add Button
                    HStack {
                        Text("Todo List")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                        Button {
                            showAddTask = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding([.horizontal, .top])

                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)

                    // Category Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(categories, id: \.self) { category in
                                FilterChip(
                                    label: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Priority Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(label: "All Priority", isSelected: selectedPriority == 0) {
                                selectedPriority = 0
                            }
                            FilterChip(label: "Low", isSelected: selectedPriority == 1) {
                                selectedPriority = 1
                            }
                            FilterChip(label: "Mid", isSelected: selectedPriority == 2) {
                                selectedPriority = 2
                            }
                            FilterChip(label: "High", isSelected: selectedPriority == 3) {
                                selectedPriority = 3
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Task List
                    if filteredTasks.isEmpty {
                        Spacer()
                        Text("Oops, looks like there's no data...")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(filteredTasks) { task in
                                TaskRow(
                                    task: task,
                                    markAsDone: {
                                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                            tasks[index].status = tasks[index].status == "DONE" ? "TODO" : "DONE"
                                        }
                                    },
                                    deleteTask: {
                                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                            tasks.remove(at: index)
                                        }
                                    }
                                )
                            }
                        }
                        .listStyle(.insetGrouped)
                        .background(Color.clear)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(tasks: $tasks, categories: categories)
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    var task: Task
    var markAsDone: () -> Void
    var deleteTask: () -> Void

    private var priorityText: String {
        switch task.priority {
        case 1: return "Low"
        case 2: return "Mid"
        case 3: return "High"
        default: return ""
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(task.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(task.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(priorityText)
                    .font(.caption2)
                    .padding(4)
                    .background(Color(.systemGray5))
                    .cornerRadius(6)
                    .foregroundColor(.primary)

                Text(task.status)
                    .font(.caption2)
                    .bold()
                    .padding(6)
                    .background(task.status == "DONE" ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: deleteTask) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(task.status == "DONE" ? "Todo" : "Done") {
                markAsDone()
            }
            .tint(task.status == "DONE" ? .orange : .green)
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray5))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var tasks: [Task]
    var categories: [String]

    @State private var title = ""
    @State private var date = Date()
    @State private var priority = 1
    @State private var category = "Personal"

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)

                DatePicker("Date", selection: $date, displayedComponents: .date)

                Picker("Priority", selection: $priority) {
                    Text("Low").tag(1)
                    Text("Mid").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())

                Picker("Category", selection: $category) {
                    ForEach(categories.filter { $0 != "All" }, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
            .navigationTitle("Add new task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTask = Task(
                            title: title,
                            date: date,
                            priority: priority,
                            status: "TODO",
                            category: category
                        )
                        tasks.append(newTask)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - SearchBar Component
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.primary)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1) 
        )
    }
}


// MARK: - Preview
struct TodoAppView_Previews: PreviewProvider {
    static var previews: some View {
        TodoAppView()
    }
}
