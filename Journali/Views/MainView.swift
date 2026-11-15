//
//  MainView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = JournalViewModel()

    @State private var showNewJournal = false
    @State private var journalToEdit: Journal?
    @State private var journalToDelete: Journal?
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.journals.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.displayedJournals) { journal in
                            JournalCardView(journal: journal) {
                                viewModel.toggleBookmark(journal)
                            }
                            .onTapGesture {
                                journalToEdit = journal
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    journalToDelete = journal
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash.fill")
                                }
                                .tint(Color.appDestructive)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            // The title "Journal" sits on the left, in the same row as the buttons
            .navigationTitle("Journal")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button("Sort by Bookmark") {
                            viewModel.sortOption = .bookmark
                        }
                        Button("Sort by Entry Date") {
                            viewModel.sortOption = .entryDate
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }

                    Button {
                        showNewJournal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                // Puts the search bar at the bottom, like your design
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
            }
            .sheet(isPresented: $showNewJournal) {
                JournalEditorView(viewModel: viewModel)
            }
            .alert("Delete Journal?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let journal = journalToDelete {
                        viewModel.delete(journal)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this journal?")
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search")
        .sheet(item: $journalToEdit) { journal in
            JournalEditorView(viewModel: viewModel, journalToEdit: journal)
        }
        .tint(Color.appTextPrimary)
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}
