//
//  ContentView.swift
//  LilyTimer
//
//  Created by Joseph Brinker on 3/24/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @State private var workIsStarted: Bool = false
    @State private var breakIsStarted: Bool = false
    @State private var isPaused: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    @State private var triedToStop = false
    
    // Timer that updates every 1 second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var workTime: Double = 0
    @State private var breakTime: Double = 0
    @State private var remainingTime: Double = 0
    @State private var remainingBreakTime: Double = 0
    
    
    var currentImageName: String {
        // If work hasn't started or there's no work time set, return the first image.
        guard workTime > 0 else { return "Stage1" }
        // Calculate elapsed work time
        let elapsed = workTime - remainingTime
        // Divide the work period into 4 phases.
        let phaseDuration = workTime / 4
        // Calculate the current phase (0 through 3)
        let phase = min(Int(elapsed / phaseDuration), 3)
        let imageNames = ["Stage1", "Stage2", "Stage3", "Stage4"]
        return imageNames[phase]
    }
    
    var body: some View {
        NavigationView {
            
            setTimerView
            
            ZStack{
                Color.black
                    .ignoresSafeArea()
                VStack{
                    if !breakIsStarted {
                        Text(workIsStarted ? "\(Int(remainingTime / 60)):\(String(format: "%02d" ,(Int(remainingTime) % 60)))" : "Start")
                            .font(.system(size: 48) .weight(.thin))
                    }
                    else {
                        Text("\(Int(remainingBreakTime / 60)):\(Int(remainingBreakTime) % 60)")
                            .font(.system(size: 48) .weight(.thin))
                    }
                    
                    Spacer()
                    
                    if breakIsStarted {
                        Image("Stage5")
                    } else {
                        Image(workIsStarted ? currentImageName : "Stage1")
                    }
                    
                    Spacer()
                    
                    // Show controls only while work timer is active
                    if workIsStarted {
                        pauseAndStop
                    }
                    // Show start button only if neither timer is active.
                    else if !breakIsStarted {
                        startButton
                        
                    }
                    // (here3)Start Button
                    else {
                        Button{
                            //Action
                            workIsStarted.toggle()
                        } label: {
                            
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text ("Enjoy Your Break"), message:
                                    Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .foregroundStyle(.white)
                .onReceive(timer) { _ in
                    if !isPaused {
                        if workIsStarted && remainingTime > 0 {
                            remainingTime -= 1
                        } else if workIsStarted && remainingTime <= 0 {
                            // When work timer ends, switch to break timer
                            workIsStarted = false
                            breakIsStarted = true
                            showAlert = true
                            workOverNotification()
                        } else if breakIsStarted && remainingBreakTime > 0 {
                            remainingBreakTime -= 1
                        } else if breakIsStarted && remainingBreakTime <= 0 {
                            // When break timer ends, no timers are running
                            breakIsStarted = false
                            breakOverNotification()
                        }
                    }
                }
                .onAppear{
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        if granted {
                            print("Notification permission granted.")
                        } else if let error = error {
                            print("Error requesting notification permission: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    private var setTimerView: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack(spacing: 100){
                VStack{
                    // Work time slider
                    Text("Work Time")
                    Slider(value: $workTime, in: 0...20, step: 1)
                        .padding()
                    Text("\(Int(workTime / 60)) Minutes")
                }
                VStack{
                    // Break time slider
                    Text("Break Time")
                    Slider(value: $breakTime, in: 0...20, step: 1)
                        .padding()
                    Text("\(Int(breakTime / 60)) Minutes")
                }
            }
        }
    }
    
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
            
            // Stop Button
            Button {
                // Stop work timer and reset times
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
                Alert(title: Text("Are you sure?"), message: Text("You will lose all progress."), primaryButton: .default(Text("Cancel")), secondaryButton: .destructive(Text("Stop")) {
                    workIsStarted = false
                    breakIsStarted = false
                    isPaused = false
                })
            }
            // Warning Alert
            .padding(.horizontal, 50)
        }
    }
    
    func workOverNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Work time is over!"
        content.body = "Time to take a break for \(String(format: "%.0f", breakTime)) minutes!"
        content.sound = .default
        
        // Trigger the notification after 1 second.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create a unique identifier for the request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the notification request to the notification center.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        print("done")
    }
    
    func breakOverNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break time is over!"
        content.body = "Hope you had a good break! Time to start your work again!"
        content.sound = .default
        
        // Trigger the notification after 1 second.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create a unique identifier for the request.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the notification request to the notification center.
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
        print("done")
    }
}


#Preview {
    ContentView()
}
