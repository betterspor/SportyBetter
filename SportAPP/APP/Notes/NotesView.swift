//
//  NotesView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Sport Notes")
                    .font(.largeTitle).bold()
                    .padding(.top, 15)
                    .padding(.leading, 5)
                
                if viewModel.notes.isEmpty {
                    EmptyStateView {
                        viewModel.prepareForAdd()
                    }
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NoteCell(note: note)
                                .onTapGesture {
                                    viewModel.prepareForEdit(note)
                                }
                        }
                        .onDelete(perform: viewModel.deleteNote)
                        .listRowBackground(Color.themeBackground)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .foregroundColor(.themePrimaryText)
            
            if viewModel.isAddEditSheetPresented {
                AddEditNoteOverlayView(
                    isPresented: $viewModel.isAddEditSheetPresented,
                    note: viewModel.noteToEdit,
                    onSave: { id, title, content, tag in
                        viewModel.addOrUpdateNote(id: id, title: title, content: content, tag: tag)
                    }
                )
            }
        }
        .onAppear(perform: viewModel.loadNotes)
    }
}


private struct NoteCell: View {
    let note: SportNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("icon_notes_cell")
                    .renderingMode(.template)
                    .foregroundColor(.themeAccentRed)
                
                Text(note.title)
                    .font(.headline)
                
                Spacer()
            }
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
                .lineLimit(3)
            
            HStack {
                if let tag = note.tag, !tag.isEmpty {
                    Label(tag, systemImage: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(16)
    }
}

private struct EmptyStateView: View {
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.themeCardBackground).frame(width: 120, height: 120)
                Image(systemName: "text.document.fill")
                    .renderingMode(.template)
                    .font(.system(size: 48))
                    .foregroundColor(.themeAccentRed)
            }
            Text("No Notes Yet").font(.title).bold()
            Text("Track your thoughts, ideas, and progress for your workouts by adding notes.")
                .font(.body)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
            
            Button(action: onAdd) {
                Label("Add Note", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding(40)
    }
}

struct AddEditNoteOverlayView: View {
    @Binding var isPresented: Bool
    let note: SportNote?
    let onSave: (UUID?, String, String, String?) -> Void
    
    @State private var title: String
    @State private var content: String
    @State private var tag: String
    @State private var isAnimating = false
    
    init(isPresented: Binding<Bool>, note: SportNote?, onSave: @escaping (UUID?, String, String, String?) -> Void) {
        self._isPresented = isPresented
        self.note = note
        self.onSave = onSave
        
        _title = State(initialValue: note?.title ?? "")
        _content = State(initialValue: note?.content ?? "")
        _tag = State(initialValue: note?.tag ?? "")
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text(note == nil ? "Add Note" : "Edit Note")
                    .font(.title2).bold()
                
                TextField("Title", text: $title)
                    .padding().background(Color.themeBackground).cornerRadius(12)
                
                TextEditor(text: $content)
                    .frame(height: 150)
                    .background {
                        if content.isEmpty {
                            VStack {
                                HStack {
                                    Text("Write your note here...")
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .padding(.top, 7)
                                        .padding(.leading, 2)
                                    Spacer()
                                }
                                Spacer()
                            }
                            
                        }
                    }
                    .padding(8).background(Color.themeBackground).cornerRadius(12)
                    .scrollContentBackground(.hidden)
                    
                
                TextField("Tag (Optional)", text: $tag)
                    .padding().background(Color.themeBackground).cornerRadius(12)
                
                Button("Save") {
                    onSave(note?.id, title, content, tag.isEmpty ? nil : tag)
                    isPresented = false
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(title.isEmpty || content.isEmpty)
            }
            .padding(24).background(Color.themeCardBackground).cornerRadius(20)
            .shadow(radius: 20).padding(30).foregroundColor(.themePrimaryText)
            .scaleEffect(isAnimating ? 1 : 0.9).opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    NotesView()
}
