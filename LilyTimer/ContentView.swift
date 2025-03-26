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
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                Text("Edit Timer Area")
                    .foregroundStyle(.white)
            }
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
                // (here3)Start Button
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
                }//
                alert(isPresented: $showAlert) {
                    if isSuccess {
                        return Alert(title: Text("Hey"), message:
                                        Text("Are you sure you want to stop!"), dismissButton:
                                .default(Text("OK")))
                    } else {
                        return Alert(title: Text ("Enjoy Your Break"), message:
                                        Text(alertMessage), dismissButton: .default(Text("OK")))
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
