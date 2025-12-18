//
//  DevicesView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

struct DevicesView: View {
    @State private var viewModel: DevicesViewModel
    
    init() {
        _viewModel = State(wrappedValue: MainActor.assumeIsolated {
            DevicesViewModel()
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Active Devices Section
                if !viewModel.activeDevices.isEmpty {
                    Section("Active Devices") {
                        ForEach(viewModel.activeDevices) { device in
                            DeviceListRow(device: device, viewModel: viewModel)
                        }
                    }
                }
                
                // All Devices Section
                Section("All Devices") {
                    if viewModel.devices.isEmpty {
                        Text("No devices found")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.devices) { device in
                            DeviceListRow(device: device, viewModel: viewModel)
                        }
                    }
                }
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await viewModel.scanForDevices()
                            }
                        } label: {
                            Label("Scan for Devices", systemImage: "arrow.clockwise")
                        }
                        
                        Button {
                            viewModel.showingAddDevice = true
                        } label: {
                            Label("Add Device Manually", systemImage: "plus")
                        }
                        
                        Button {
                            viewModel.resetAllDailyUsage()
                        } label: {
                            Label("Reset All Usage", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.scanForDevices()
            }
            .sheet(isPresented: $viewModel.showingAddDevice) {
                AddDeviceView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingDeviceDetail) {
                if let device = viewModel.selectedDevice {
                    DeviceDetailView(device: device, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Device List Row

struct DeviceListRow: View {
    let device: Device
    @Bindable var viewModel: DevicesViewModel
    
    var body: some View {
        Button {
            viewModel.selectDevice(device)
        } label: {
            HStack {
                // Device Icon
                Image(systemName: deviceIcon)
                    .font(.title2)
                    .foregroundColor(device.isActive ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(device.ipAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let limit = device.dailyTimeLimit {
                        ProgressView(value: Double(device.timeUsedToday), total: Double(limit))
                            .progressViewStyle(.linear)
                        Text("\(device.timeUsedToday)/\(limit) minutes used")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if device.isBlocked {
                        Label("Blocked", systemImage: "hand.raised.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if device.hasExceededTimeLimit {
                        Label("Limit", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    
                    if device.totalBlockedAttempts > 0 {
                        Text("\(device.totalBlockedAttempts) blocks")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                viewModel.removeDevice(device)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                viewModel.toggleDeviceBlock(device)
            } label: {
                Label(device.isBlocked ? "Unblock" : "Block", 
                      systemImage: device.isBlocked ? "checkmark" : "hand.raised")
            }
            .tint(device.isBlocked ? .green : .red)
        }
    }
    
    private var deviceIcon: String {
        // Could be enhanced to detect device type
        "iphone"
    }
}

// MARK: - Add Device View

struct AddDeviceView: View {
    @Bindable var viewModel: DevicesViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var ipAddress = ""
    @State private var macAddress = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Device Information") {
                    TextField("Device Name", text: $name)
                    TextField("IP Address", text: $ipAddress)
                        .keyboardType(.decimalPad)
                    TextField("MAC Address", text: $macAddress)
                        .textInputAutocapitalization(.characters)
                }
                
                Section {
                    Button("Add Device") {
                        viewModel.addManualDevice(
                            name: name,
                            ipAddress: ipAddress,
                            macAddress: macAddress
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || ipAddress.isEmpty || macAddress.isEmpty)
                }
            }
            .navigationTitle("Add Device")
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

// MARK: - Device Detail View

struct DeviceDetailView: View {
    let device: Device
    @Bindable var viewModel: DevicesViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var editedName: String
    @State private var timeLimit: Double
    
    init(device: Device, viewModel: DevicesViewModel) {
        self.device = device
        self.viewModel = viewModel
        _editedName = State(initialValue: device.name)
        _timeLimit = State(initialValue: Double(device.dailyTimeLimit ?? 0))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Device Information") {
                    TextField("Device Name", text: $editedName)
                    
                    LabeledContent("IP Address", value: device.ipAddress)
                    LabeledContent("MAC Address", value: device.macAddress)
                    LabeledContent("First Seen", value: device.firstConnected.formatted())
                    LabeledContent("Last Seen", value: device.lastSeen.formatted())
                }
                
                Section("Status") {
                    Toggle("Block Device", isOn: .constant(device.isBlocked))
                        .onChange(of: device.isBlocked) { oldValue, newValue in
                            viewModel.toggleDeviceBlock(device)
                        }
                    
                    LabeledContent("Total Blocks", value: "\(device.totalBlockedAttempts)")
                    LabeledContent("Status", value: device.isActive ? "Active" : "Inactive")
                }
                
                Section("Time Limit") {
                    Toggle("Enable Time Limit", isOn: .constant(device.dailyTimeLimit != nil))
                    
                    if device.dailyTimeLimit != nil {
                        VStack(alignment: .leading) {
                            Text("Daily Limit: \(Int(timeLimit)) minutes")
                            Slider(value: $timeLimit, in: 0...480, step: 30)
                        }
                        
                        LabeledContent("Used Today", value: "\(device.timeUsedToday) minutes")
                        
                        if let remaining = device.remainingTime {
                            LabeledContent("Remaining", value: "\(remaining) minutes")
                        }
                        
                        Button("Reset Daily Usage") {
                            viewModel.resetDailyUsage(for: device)
                        }
                    }
                }
                
                Section {
                    Button("Save Changes", action: saveChanges)
                        .frame(maxWidth: .infinity)
                    
                    Button("Delete Device", role: .destructive) {
                        viewModel.removeDevice(device)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(device.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        // Create local copies to avoid capturing mutable variables
        let updatedName = editedName
        let updatedTimeLimit = timeLimit > 0 ? Int(timeLimit) : nil
        let deviceCopy = device
        
        Task { @MainActor [updatedName, updatedTimeLimit, deviceCopy] in
            var updated = deviceCopy
            updated.name = updatedName
            updated.dailyTimeLimit = updatedTimeLimit
            
            viewModel.updateDeviceName(updated, name: updatedName)
            viewModel.setTimeLimit(for: updated, minutes: updatedTimeLimit)
        }
        
        dismiss()
    }
}

#Preview {
    DevicesView()
}
