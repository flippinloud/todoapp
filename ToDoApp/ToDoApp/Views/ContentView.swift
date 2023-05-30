//
//  ContentView.swift
//  ToDoApp
//
//  Created by Steve Gregory on 25/5/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var todos: [ToDoModel] = []
    @State private var showTodoView = false
    @State private var hasReturnedFromDetailView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(todos.indices, id: \.self) { index in
                    NavigationLink(destination: ToDoDetailView(todo: todos[index])) {
                        ToDoRow(record: todos[index])
                    }
                }
            }
            .onAppear(perform: loadToDoList)
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: Button(action: {
                self.showTodoView = true
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $showTodoView, onDismiss: {
            self.loadToDoList()
        }) {
            ToDoDetailView(todo: ToDoModel(id: 0, title: "", completed: false), onDismiss: { newTodo in
                self.todos.append(newTodo)
                self.hasReturnedFromDetailView = true
            })
        }
    }
    
    func loadToDoList() {
        //needs a bit more logic around this so that it only looks at the cache at startup
        //at the moment this is going to pull the cached data when you come back from an update / delete
        //taking it out due to time constraints
        
//        if let cachedData = UserDefaults.standard.data(forKey: "todos"),
//           let cachedTodos = try? JSONDecoder().decode([ToDoModel].self, from: cachedData) {
//            todos = cachedTodos
//            print ("pulled data from cache")
//        } else {
            API.shared.getToDo { todos in
                self.todos = todos
                // Cache the data in UserDefaults
                if let encodedData = try? JSONEncoder().encode(todos) {
                    UserDefaults.standard.set(encodedData, forKey: "todos")
                }
//            }
        }
    }
}

struct ToDoRow: View {
    let record: ToDoModel

    var body: some View {
        HStack {
            Image(systemName: record.completed ? "checkmark.square.fill" : "square")
                .foregroundColor(record.completed ? .green : .gray)
            Text(record.title)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
