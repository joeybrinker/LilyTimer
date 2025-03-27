//
//  ContentView.swift
//  LilyTimer
//
//  Created by Joseph Brinker on 3/24/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    // MARK: - State Variables
    
    /// Indicates if the work timer is active.
    @State private var workIsStarted = false
    /// Indicates if the break timer is active.
    @State private var breakIsStarted = false
    /// Indicates if the timer is currently paused.
    @State private var isPaused = false
    /// Controls whether an alert is shown.
    @State private var showAlert = false
    /// Message to display in the alert.
    @State private var alertMessage = ""
    /// Used for future success indication.
    @State private var isSuccess = false
    /// Controls whether the stop confirmation alert is shown.
    @State private var triedToStop = false
    
    // MARK: - Timer Properties
    
    /// Timer publisher that fires every second.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Total work time (in seconds) set by the user.
    @State private var workTime: Double = 3600
    /// Total break time (in seconds) set by the user.
    @State private var breakTime: Double = 900
    /// Remaining time (in seconds) for the work period.
    @State private var remainingTime: Double = 0
    /// Remaining time (in seconds) for the break period.
    @State private var remainingBreakTime: Double = 0

    // MARK: - Computed Properties
    
    /// Returns the name of the current stage image based on work progress.
    var currentImageName: String {
        // If work hasn't started or there's no work time set, return the default image.
        guard workTime > 0 else { return "Stage1" }
        
        // Calculate elapsed work time.
        let elapsed = workTime - remainingTime
        // Divide the work period into 4 phases.
        let phaseDuration = workTime / 4
        // Determine the current phase (0 through 3).
        let phase = min(Int(elapsed / phaseDuration), 3)
        let imageNames = ["Stage1", "Stage2", "Stage3", "Stage4"]
        return imageNames[phase]
    }
    
    /// Formats the work timer text as "minutes:seconds", always showing two digits for seconds.
    private var workTimerText: String {
        let minutes = Int(remainingTime / 60)
        let seconds = Int(remainingTime) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    /// Formats the break timer text as "minutes:seconds", always showing two digits for seconds.
    private var breakTimerText: String {
        let minutes = Int(remainingBreakTime / 60)
        let seconds = Int(remainingBreakTime) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            // Background view for timer setup.
            setTimerView
            
            // Main timer and control view.
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    // Timer display
                    if !breakIsStarted {
                        Text(workIsStarted ? workTimerText : "Start Work")
                            .font(.system(size: 48).weight(.thin))
                    } else {
                        Text(breakTimerText)
                            .font(.system(size: 48).weight(.thin))
                    }
                    
                    Spacer()
                    
                    // Display stage image based on timer state.
                    if breakIsStarted {
                        Image("Stage5")
                    } else {
                        Image(workIsStarted ? currentImageName : "Stage1")
                    }
                    
                    Spacer()
                    
                    // Show controls based on timer state.
                    if workIsStarted {
                        pauseAndStop
                    } else if !breakIsStarted {
                        startButton
                    } else {
                        // This branch is reached when break is active and work is not;
                        // Show a button to start work again after a break.
                        Button {
                            workIsStarted.toggle()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .frame(width: 310, height: 90)
                                    .foregroundStyle(.gray)
                                Text("Start Work")
                                    .font(.system(size: 48).weight(.thin))
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Enjoy Your Break"),
                                  message: Text(alertMessage),
                                  dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .foregroundStyle(.white)
                
                // MARK: - Timer Update Logic
                .onReceive(timer) { _ in
                    if workIsStarted && remainingTime > 0 {
                        remainingTime -= 1
                    } else if workIsStarted && remainingTime <= 0 {
                        // Work timer ended: switch to break timer.
                        workIsStarted = false
                        breakIsStarted = true
                        showAlert = true
                        workOverNotification()
                    } else if breakIsStarted && remainingBreakTime > 0 {
                        remainingBreakTime -= 1
                    } else if breakIsStarted && remainingBreakTime <= 0 {
                        // Break timer ended.
                        breakIsStarted = false
                        breakOverNotification()
                    }
                }
                .onAppear {
                    requestNotificationPermissions()
                }
            }
        }
    }
    

    
    // MARK: - Notification Permission
    
    /// Requests permission from the user to display notifications.
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// View for setting up the timer durations.
    private var setTimerView: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack(spacing: 100) {
                // Work time slider
                VStack {
                    Text("Work Time")
                    Slider(value: $workTime, in: 0...3600, step: 60)
                        .padding()
                    Text("\(Int(workTime / 60)) Minutes")
                }
                // Break time slider
                VStack {
                    Text("Break Time")
                    Slider(value: $breakTime, in: 0...1800, step: 60)
                        .padding()
                    Text("\(Int(breakTime / 60)) Minutes")
                }
            }
        }
    }
    
    /// Button to start the timers.
    private var startButton: some View {
        Button {
            workIsStarted = true
            remainingTime = workTime
            remainingBreakTime = breakTime
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .frame(width: 310, height: 90)
                    .foregroundStyle(.gray)
                Text("Start")
                    .font(.system(size: 48).weight(.thin))
            }
        }
        .padding(.horizontal, 50)
    }
    
    /// View containing pause/play and stop controls.
    private var pauseAndStop: some View {
        HStack {
            // Pause/Play Button
            Button {
                isPaused.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .frame(width: 90, height: 90)
                        .foregroundStyle(.gray)
                    Image(systemName: isPaused ? "play.fill" : "pause")
                        .font(.system(size: 48).weight(.thin))
                }
            }
            .padding(.horizontal, 50)
            
            // Stop Button with confirmation alert.
            Button {
                triedToStop = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .frame(width: 90, height: 90)
                        .foregroundStyle(.red)
                    Image(systemName: "stop.circle")
                        .font(.system(size: 48).weight(.thin))
                }
            }
            .alert(isPresented: $triedToStop) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("You will lose all progress."),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Stop")) {
                        // Reset timers when stopping.
                        workIsStarted = false
                        breakIsStarted = false
                        isPaused = false
                    }
                )
            }
            .padding(.horizontal, 50)
        }
    }
    
    // MARK: - Local Notification Functions
    
    /// Schedules a notification when the work timer ends.
    private func workOverNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Work time is over!"
        content.body = "Time to take a break for \(String(format: "%.0f", breakTime)) minutes!"
        content.sound = .default
        
        // Trigger the notification after 1 second.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create and add the notification request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling work notification: \(error.localizedDescription)")
            }
        }
        print("Work over notification scheduled.")
    }
    
    /// Schedules a notification when the break timer ends.
    private func breakOverNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break time is over!"
        content.body = "Hope you had a good break! Time to start your work again!"
        content.sound = .default
        
        // Trigger the notification after 1 second.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create and add the notification request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break notification: \(error.localizedDescription)")
            }
        }
        print("Break over notification scheduled.")
    }
}

#Preview {
    ContentView()
}
