//
//  ContentView.swift
//  LilyTimer
//
//  Created by Joseph Brinker on 3/24/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var workIsStarted: Bool = false
    @State private var breakIsStarted: Bool = false
    @State private var isPaused: Bool = false
    
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
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                VStack(spacing: 100){
                    VStack{
                        Text("Work Time")
                        Slider(value: $workTime, in: 0...60, step: 1)
                            .padding()
                        Text("\(Int(workTime / 60)) Minutes")
                    }
                    VStack{
                        Text("Break Time")
                        Slider(value: $breakTime, in: 0...60, step: 1)
                            .padding()
                        Text("\(Int(breakTime / 60)) Minutes")
                    }
                }
                
            }
            ZStack{
                Color.black
                    .ignoresSafeArea()
                VStack{
                    if !breakIsStarted {
                        Text(workIsStarted ? "\(Int(remainingTime / 60)):\(Int(remainingTime) % 60)" : "Start")
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
                                workIsStarted = false
                                remainingTime = workTime
                                remainingBreakTime = breakTime
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24)
                                        .frame(width: 90, height: 90)
                                        .foregroundStyle(.red)
                                    Image(systemName: "stop.circle")
                                        .font(.system(size: 48).weight(.thin))
                                }
                            }
                            .padding(.horizontal, 50)
                        }
                    }
                    // Show start button only if neither timer is active.
                    else if !breakIsStarted {
                        Button {
                            workIsStarted = true
                            isPaused = false
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
                    }
                }
                .padding()
            }
            .onReceive(timer) { _ in
                if !isPaused {
                    if workIsStarted && remainingTime > 0 {
                        remainingTime -= 1
                    } else if workIsStarted && remainingTime <= 0 {
                        // When work timer ends, switch to break timer
                        workIsStarted = false
                        breakIsStarted = true
                    } else if breakIsStarted && remainingBreakTime > 0 {
                        remainingBreakTime -= 1
                    } else if breakIsStarted && remainingBreakTime <= 0 {
                        // When break timer ends, no timers are running
                        breakIsStarted = false
                    }
                }
            }

        }
        .foregroundStyle(.white)
    }
    
}

#Preview {
    ContentView()
}
