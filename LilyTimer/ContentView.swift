//
//  ContentView.swift
//  LilyTimer
//
//  Created by Joseph Brinker on 3/24/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isStarted: Bool = false
    @State private var isPaused: Bool = false
        
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                Text("Edit Timer Area")
                    .foregroundStyle(.white)
            }
            ZStack{
                Color.black
                    .ignoresSafeArea()
                VStack{
                    Text("Timer Placeholder")
                        .font(.system(size: 48) .weight(.thin))
                    
                    Spacer()
                    
                    Image("Stage1")
                    
                    Spacer()
                    
                    if isStarted {
                        HStack{
                            
                            // Pause Button
                            Button{
                                //Action
                                isPaused.toggle()
                                
                                //toggle timer
                            }
                            label: {
                                if isPaused {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 24)
                                            .frame(width: 90, height: 90)
                                            .foregroundStyle(.gray)
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 48) .weight(.thin))
                                    }
                                }
                                else {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 24)
                                            .frame(width: 90, height: 90)
                                            .foregroundStyle(.gray)
                                        Image(systemName: "pause")
                                            .font(.system(size: 48) .weight(.thin))
                                    }
                                }
                            }
                            .padding(.horizontal, 50)
                            
                            // Stop Button
                            Button{
                                
                                //Action
                                isStarted.toggle()
                            }
                            label: {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 24)
                                        .frame(width: 90, height: 90)
                                        .foregroundStyle(.red)
                                    Image(systemName: "stop.circle")
                                        .font(.system(size: 48) .weight(.thin))
                                }
                            }
                            .padding(.horizontal, 50)

                        }
                    }
                    // Start Button
                    else{
                        Button{
                            //Action
                            isStarted.toggle()
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 24)
                                    .frame(width: 310, height: 90)
                                    .foregroundStyle(.gray)
                                Text("Start")
                                    .font(.system(size: 48) .weight(.thin))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    ContentView()
}
