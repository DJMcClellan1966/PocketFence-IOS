//
//  BlockedSitesView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

struct BlockedSitesView: View {
    @State private var viewModel: BlockedSitesViewModel
    
    init() {
        _viewModel = State(wrappedValue: MainActor.assumeIsolated {
            BlockedSitesViewModel()
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Categories Section
                Section("Block by Category") {
                    ForEach(WebsiteCategory.allCases.filter { $0 != .custom }) { category in
                        CategoryRow(
                            category: category,
                            count: viewModel.getCategoryBlockedCount(category),
                            isBlocked: viewModel.isCategoryBlocked(category),
                            onToggle: {
                                if viewModel.isCategoryBlocked(category) {
                                    viewModel.unblockCategory(category)
                                } else {
                                    viewModel.blockCategory(category)
                                }
                            }
                        )
                    }
                }
                
                // Blocked Sites Section
                Section {
                    if viewModel.filteredSites.isEmpty {
                        Text("No blocked sites")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.filteredSites) { site in
                            BlockedSiteRow(site: site, viewModel: viewModel)
                        }
                    }
                } header: {
                    HStack {
                        Text("Blocked Sites (\(viewModel.filteredSites.count))")
                        Spacer()
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search domains")
            .navigationTitle("Blocked Sites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showingAddSite = true
                        } label: {
                            Label("Add Site", systemImage: "plus")
                        }
                        
                        Menu("Filter by Category") {
                            Button("All") {
                                viewModel.selectedCategory = nil
                            }
                            ForEach(WebsiteCategory.allCases) { category in
                                Button(category.rawValue) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        
                        Divider()
                        
                        Button {
                            viewModel.enableAllSites()
                        } label: {
                            Label("Enable All", systemImage: "checkmark.circle")
                        }
                        
                        Button {
                            viewModel.disableAllSites()
                        } label: {
                            Label("Disable All", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSite) {
                AddBlockedSiteView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: WebsiteCategory
    let count: Int
    let isBlocked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.headline)
                
                Text(category.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isBlocked {
                Text("\(count) sites")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: onToggle) {
                Text(isBlocked ? "Unblock" : "Block")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isBlocked ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Blocked Site Row

struct BlockedSiteRow: View {
    let site: BlockedWebsite
    @Bindable var viewModel: BlockedSitesViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(site.displayDomain)
                    .font(.subheadline)
                    .strikethrough(!site.isEnabled)
                
                HStack {
                    Label(site.category.rawValue, systemImage: site.category.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if site.blockCount > 0 {
                        Text("• \(site.blockCount) blocks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(site.isEnabled))
                .labelsHidden()
                .onChange(of: site.isEnabled) { oldValue, newValue in
                    viewModel.toggleSiteEnabled(site)
                }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.removeSite(site)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Blocked Site View

struct AddBlockedSiteView: View {
    @Bindable var viewModel: BlockedSitesViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var domain = ""
    @State private var selectedCategory: WebsiteCategory = .custom
    
    var body: some View {
        NavigationView {
            Form {
                Section("Website Information") {
                    TextField("Domain (e.g., example.com)", text: $domain)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(WebsiteCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section {
                    Text("Enter the domain without http:// or www.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Add to Blocklist") {
                        viewModel.addBlockedSite(domain: domain, category: selectedCategory)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                    .disabled(domain.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Add Blocked Site")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BlockedSitesView()
}
