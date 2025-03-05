//
//  WikiArticleCardView.swift
//  Lume
//
//  Created by Khushmeet Singh on 3/3/25.
//

import SwiftUI

struct WikiArticleCardView: View {
    let wikiArticle: WikiArticle
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView(for: wikiArticle, in: geometry)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(wikiArticle.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(.top, 50)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Wikipedia")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(wikiArticle.extract)
                            .font(.body)
                            .lineLimit(showContent ? nil : 3)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.7))
                            .shadow(radius: 10)
                    )
                    .padding()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showContent.toggle()
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    private func backgroundView(for article: WikiArticle, in geometry: GeometryProxy) -> some View {
        Group {
            if let thumbnail = article.thumbnail {
                AsyncImage(url: URL(string: thumbnail.source)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                        )
                } placeholder: {
                    gradientBackground
                }
            } else {
                gradientBackground
            }
        }
        .clipped()
    }
    
    private var gradientBackground: some View {
        LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(
                LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
            )
    }
}
