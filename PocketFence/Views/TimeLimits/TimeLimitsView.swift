//
//  TimeLimitsView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

struct TimeLimitsView: View {
    @State private var viewModel: TimeLimitsViewModel
    
    init() {
        _viewModel = State(wrappedValue: MainActor.assumeIsolated {
            TimeLimitsViewModel()
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Quiet Hours Section
                Section {
                    if let quietHours = viewModel.globalQuietHours {
                        QuietHoursRow(quietHours: quietHours, viewModel: viewModel)
                    } else {
                        Button {
                            viewModel.showingQuietHoursEditor = true
                        } label: {
                            Label("Add Quiet Hours", systemImage: "plus.circle.fill")
                        }
                    }
                } header: {
                    Text("Quiet Hours")
                } footer: {
                    Text("Block internet access during specific hours")
                }
                
                // Global Time Limit Section
                Section {
                    if let globalLimit = viewModel.getGlobalTimeLimit() {
                        TimeLimitRow(timeLimit: globalLimit, deviceName: "All Devices", viewModel: viewModel)
                    } else {
                        Button {
                            viewModel.setTimeLimit(for: nil, minutes: 120)
                        } label: {
                            Label("Set Global Time Limit", systemImage: "plus.circle.fill")
                        }
                    }
                } header: {
                    Text("Global Time Limit")
                } footer: {
                    Text("Applies to all devices by default")
                }
                
                // Per-Device Time Limits
                Section {
                    if viewModel.devicesWithLimits.isEmpty {
                        Text("No device-specific limits")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.devicesWithLimits) { device in
                            if let timeLimit = viewModel.getTimeLimit(for: device) {
                                NavigationLink {
                                    EditTimeLimitView(
                                        device: device,
                                        timeLimit: timeLimit,
                                        viewModel: viewModel
                                    )
                                } label: {
                                    TimeLimitRow(
                                        timeLimit: timeLimit,
                                        deviceName: device.displayName,
                                        viewModel: viewModel
                                    )
                                }
                            }
                        }
                    }
                } header: {
                    Text("Device Time Limits")
                } footer: {
                    Text("Override global limit for specific devices")
                }
                
                // Devices Without Limits
                if !viewModel.devicesWithoutLimits.isEmpty {
                    Section("Add Limit to Device") {
                        ForEach(viewModel.devicesWithoutLimits) { device in
                            Button {
                                viewModel.setTimeLimit(for: device.id, minutes: 120)
                            } label: {
                                HStack {
                                    Image(systemName: "iphone")
                                        .foregroundColor(.blue)
                                    Text(device.displayName)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Time Limits")
            .sheet(isPresented: $viewModel.showingQuietHoursEditor) {
                QuietHoursEditorView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Quiet Hours Row

struct QuietHoursRow: View {
    let quietHours: QuietHours
    @Bindable var viewModel: TimeLimitsViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quiet Hours")
                    .font(.headline)
                
                Text(quietHours.displayTimeRange)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(daysText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(quietHours.isEnabled))
                .labelsHidden()
                .onChange(of: quietHours.isEnabled) { oldValue, newValue in
                    viewModel.toggleQuietHoursEnabled()
                }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.removeQuietHours()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                viewModel.showingQuietHoursEditor = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
    }
    
    private var daysText: String {
        if quietHours.daysOfWeek.count == 7 {
            return "Every day"
        } else if quietHours.daysOfWeek.count == 5 && !quietHours.daysOfWeek.contains(1) && !quietHours.daysOfWeek.contains(7) {
            return "Weekdays"
        } else if quietHours.daysOfWeek.count == 2 && quietHours.daysOfWeek.contains(1) && quietHours.daysOfWeek.contains(7) {
            return "Weekends"
        } else {
            return "\(quietHours.daysOfWeek.count) days"
        }
    }
}

// MARK: - Time Limit Row

struct TimeLimitRow: View {
    let timeLimit: TimeLimit
    let deviceName: String
    @Bindable var viewModel: TimeLimitsViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(deviceName)
                    .font(.headline)
                
                Text("\(timeLimit.dailyLimitMinutes) minutes per day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: .constant(timeLimit.isEnabled))
                .labelsHidden()
                .onChange(of: timeLimit.isEnabled) { oldValue, newValue in
                    viewModel.toggleTimeLimitEnabled(timeLimit)
                }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.removeTimeLimit(timeLimit)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Edit Time Limit View

struct EditTimeLimitView: View {
    let device: Device
    let timeLimit: TimeLimit
    @Bindable var viewModel: TimeLimitsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var limitMinutes: Double
    
    init(device: Device, timeLimit: TimeLimit, viewModel: TimeLimitsViewModel) {
        self.device = device
        self.timeLimit = timeLimit
        self.viewModel = viewModel
        _limitMinutes = State(initialValue: Double(timeLimit.dailyLimitMinutes))
    }
    
    var body: some View {
        Form {
            Section("Device") {
                LabeledContent("Name", value: device.displayName)
                LabeledContent("IP Address", value: device.ipAddress)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Limit: \(viewModel.formatTimeRemaining(Int(limitMinutes)))")
                        .font(.headline)
                    
                    Slider(value: $limitMinutes, in: 30...480, step: 30)
                    
                    HStack {
                        Text("30 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("8 hours")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Time Limit")
            }
            
            Section {
                LabeledContent("Used Today", value: "\(device.timeUsedToday) minutes")
                if let remaining = device.remainingTime {
                    LabeledContent("Remaining", value: viewModel.formatTimeRemaining(remaining))
                }
            }
            
            Section {
                Button("Save") {
                    viewModel.setTimeLimit(for: device.id, minutes: Int(limitMinutes))
                    dismiss()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Edit Time Limit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Quiet Hours Editor View

struct QuietHoursEditorView: View {
    @Bindable var viewModel: TimeLimitsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var startTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var endTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    @State private var selectedDays: Set<Int> = Set(1...7)
    
    private let daysOfWeek = [
        (1, "Sunday"),
        (2, "Monday"),
        (3, "Tuesday"),
        (4, "Wednesday"),
        (5, "Thursday"),
        (6, "Friday"),
        (7, "Saturday")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Time Range") {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section("Active Days") {
                    ForEach(daysOfWeek, id: \.0) { day in
                        Toggle(day.1, isOn: Binding(
                            get: { selectedDays.contains(day.0) },
                            set: { isOn in
                                if isOn {
                                    selectedDays.insert(day.0)
                                } else {
                                    selectedDays.remove(day.0)
                                }
                            }
                        ))
                    }
                }
                
                Section {
                    Button("Save Quiet Hours") {
                        viewModel.setQuietHours(
                            startTime: startTime,
                            endTime: endTime,
                            daysOfWeek: selectedDays
                        )
                        dismiss()
                    }
                    .disabled(selectedDays.isEmpty)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Quiet Hours")
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
    TimeLimitsView()
}
