//
//  HomeView.swift
//  cruxx
//
//  Created by Lee Seung Ho on 7/2/25.
//
import SwiftUI

struct HomeView: View {
    @Binding var showRecordingView: Bool
    
    var body: some View {
        ZStack{
            GeometryReader { geo in
                let width = geo.size.width * 0.8
                let height = width * 16 / 9
                Image("mockup_thumbnail")
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .grayscale(1.0)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                            .frame(width: width, height: height)
                    )
                
                VStack {
                    Spacer(minLength: geo.size.height * 0.08)
                    HStack {
                        Spacer()
                        Text("마지막 등반")
                            .font(.custom("BookkMyungjo-Lt", size: 10))
                        Circle()
                            .fill(Color.black)
                            .frame(width: 5, height: 5)
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 5, height: 5)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: geo.size.width * 0.1)
                    }
                    Spacer(minLength: geo.size.height * 0.10)
                    HStack{
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 16)
                        
                        Text("CRUXX")
                            .font(.custom("ZillaSlab-Bold", size: 45))
                            .foregroundStyle(.white)
                            .padding(.vertical, 4)
                            .background(Color.black)
                        Spacer()
                    }
                    Spacer(minLength: geo.size.height * 0.60)
                    
                    Button(action: {
                        showRecordingView = true
                    }) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                            
                            Text("Record Start")
                                .font(.custom("ZillaSlab-Regular", size: 40))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(Color.black)
                    
                    Spacer(minLength: geo.size.height * 0.15)
                }
                
            }
        }
    }
}
