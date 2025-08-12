//
//  NotesViewModel.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import Foundation

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [SportNote] = []
    @Published var isAddEditSheetPresented = false
    @Published var noteToEdit: SportNote?
    
    private let notesKey = "sport_notes"
    
    init() {
        loadNotes()
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(handleDataReset),
                  name: .didRequestDataReset,
                  object: nil
              )
    }
    
    @objc private func handleDataReset() {
           self.notes = []
           loadNotes()
       }
    
    func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: notesKey),
              let savedNotes = try? JSONDecoder().decode([SportNote].self, from: data) else {
            self.notes = []
            return
        }
        self.notes = savedNotes.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: notesKey)
        }
    }
    
    func addOrUpdateNote(id: UUID? = nil, title: String, content: String, tag: String?) {
        if let id = id, let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].tag = tag
        } else {
            let newNote = SportNote(id: UUID(), title: title, content: content, tag: tag, createdAt: Date())
            notes.insert(newNote, at: 0)
        }
        saveNotes()
        loadNotes()
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    func prepareForEdit(_ note: SportNote) {
        noteToEdit = note
        isAddEditSheetPresented = true
    }
    
    func prepareForAdd() {
        noteToEdit = nil
        isAddEditSheetPresented = true
    }
}
