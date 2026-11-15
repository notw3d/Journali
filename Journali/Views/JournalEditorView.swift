//
//  JournalEditorView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct JournalEditorView: View {
    @ObservedObject var viewModel: JournalViewModel
    let journalToEdit: Journal?

    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var text: String
    @State private var showDiscardDialog = false
    @FocusState private var isTitleFocused: Bool

    // If journalToEdit is nil, this is a NEW journal. Otherwise we are editing.
    init(viewModel: JournalViewModel, journalToEdit: Journal? = nil) {
        self.viewModel = viewModel
        self.journalToEdit = journalToEdit
        _title = State(initialValue: journalToEdit?.title ?? "")
        _text = State(initialValue: journalToEdit?.text ?? "")
    }

    private var hasChanges: Bool {
        title != (journalToEdit?.title ?? "") || text != (journalToEdit?.text ?? "")
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var dateText: String {
        Journal.format(journalToEdit?.date ?? Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: X on the left, ✓ on the right
            HStack {
                Button {
                    if hasChanges {
                        showDiscardDialog = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle().stroke(Color.appTextSecondary.opacity(0.4), lineWidth: 1)
                        }
                }

                Spacer()

                Button {
                    saveJournal()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appBackground)
                        .frame(width: 40, height: 40)
                        .background(Color.appAccent, in: Circle())
                }
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.4)
            }
            .padding(.bottom, 24)

            // Title
            TextField(
                "",
                text: $title,
                prompt: Text("Title").foregroundStyle(Color.appTextSecondary.opacity(0.5))
            )
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Color.appTextPrimary)
            .focused($isTitleFocused)

            // Date
            Text(dateText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 6)

            // Journal text, with a placeholder shown while it is empty
            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.appTextPrimary)
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .padding(.horizontal, -5)

                if text.isEmpty {
                    Text("Type your Journal...")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(.top, 20)
        }
        .padding(20)
        .tint(Color.appAccent)
        .presentationBackground(Color.appCard)
        .presentationDragIndicator(.visible)
        .confirmationDialog(
            "Are you sure you want to discard changes on this journal?",
            isPresented: $showDiscardDialog,
            titleVisibility: .visible
        ) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            // A normal button (not a cancel button), so it is always shown
            Button("Keep Editing") { }
        }
        .onAppear {
            if journalToEdit == nil {
                isTitleFocused = true
            }
        }
    }

    private func saveJournal() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let journal = journalToEdit {
            if hasChanges {
                viewModel.update(journal, title: cleanTitle, text: text)
            }
        } else {
            viewModel.add(title: cleanTitle, text: text)
        }
        dismiss()
    }
}

#Preview {
    JournalEditorView(viewModel: JournalViewModel())
        .preferredColorScheme(.dark)

}
