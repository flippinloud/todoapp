//
//  ToDoDetailView.swift
//  ToDoApp
//
//  Created by Steve Gregory on 25/5/2023.
//

import SwiftUI

struct ToDoDetailView: View {
    enum AlertType: Identifiable {
        case create, update, delete
        
        var id: String {
            switch self {
            case .create:
                return "create"
            case .update:
                return "update"
            case .delete:
                return "delete"
            }
        }
    }
    
    let todo: ToDoModel
    @State private var updatedTitle: String
    @State private var updatedCompleted: Bool
    @State private var selectedAlert: AlertType?
    @Environment(\.presentationMode) var presentationMode
    
    var onDismiss: ((ToDoModel) -> Void)?
    
    public init(todo: ToDoModel, onDismiss: ((ToDoModel) -> Void)? = nil) {
        self.todo = todo
        self.onDismiss = onDismiss
        _updatedTitle = State(initialValue: todo.title)
        _updatedCompleted = State(initialValue: todo.completed)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: $updatedTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle("Completed", isOn: $updatedCompleted)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(todo.id == 0 ? "Create" : "Update") {
                    if todo.id == 0 {
                        let newTodo = ToDoModel(id: 0, title: updatedTitle, completed: updatedCompleted)
                        API.shared.createToDo(todo: newTodo) { result in
                            switch result {
                            case .success(let createdTodo):
                                DispatchQueue.main.async {
                                    self.updatedTitle = createdTodo.title
                                    self.updatedCompleted = createdTodo.completed
                                    self.selectedAlert = .create
                                }
                            case .failure(let error):
                                print("Error creating todo: \(error)")
                            }
                        }
                    } else {
                        let updatedTodo = ToDoModel(id: todo.id, title: updatedTitle, completed: updatedCompleted)
                        API.shared.updateToDo(todo: updatedTodo) { result in
                            switch result {
                            case .success(let updatedTodo):
                                DispatchQueue.main.async {
                                    self.updatedTitle = updatedTodo.title
                                    self.updatedCompleted = updatedTodo.completed
                                    self.selectedAlert = .update
                                }
                                print("Todo updated: \(updatedTodo)")
                            case .failure(let error):
                                print("Error updating todo: \(error)")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Delete") {
                    self.selectedAlert = .delete
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(8)
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(8)
            }
        }
        .padding()
        .alert(item: $selectedAlert) { alertType in
            switch alertType {
            case .create:
                return Alert(
                    title: Text("Success"),
                    message: Text("The record was created successfully."),
                    dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            case .update:
                return Alert(
                    title: Text("Success"),
                    message: Text("The record was updated successfully."),
                    dismissButton: .default(Text("OK"), action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                )
            case .delete:
                return Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete this record?"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        API.shared.deleteToDo(todo: todo) { result in
                            switch result {
                            case .success:
                                presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                print("Error deleting todo: \(error)")
                            }
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
