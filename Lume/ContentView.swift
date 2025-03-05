//
//  ContentView.swift
//  Lume
//
//  Created by Khushmeet Singh on 2/25/25.
//

import UIKit
import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel = WikiArticleViewModel()
    @State private var currentIndex = 0

    var body: some View {
        ZStack {
            if viewModel.articles.isEmpty {
                MainLoadingView()
                    .onAppear {
                        viewModel.loadArticles()
                    }
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                        WikiArticleCardView(wikiArticle: article)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .environment(\.layoutDirection, .rightToLeft)
                .ignoresSafeArea()
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.loadArticles()
        }
    }
                
//                VStack {
//                    HStack {
//                        Image(systemName: "w.circle.fill")
//                            .font(.largeTitle)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Circle().fill(Color.black.opacity(0.5)))
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            viewModel.loadArticles()
//                        }) {
//                            Image(systemName: "arrow.clockwise")
//                                .font(.title)
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(Circle().fill(Color.black.opacity(0.5)))
//                        }
//                    }
//                    .padding()
//                    
//                    Spacer()
//                }
//            }
    
//    private func setupVerticalScrolling() {
//        UIPageControl.appearance().isHidden = true
//        
//        let indexViewClass = UIView.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
//        indexViewClass.backgroundColor = .clear
//        
//        let swipeDirectionKey = UIPageViewController.OptionsKey.navigationOrientation
//        
//        guard let hostingController = UIApplication.shared.windows.first?.rootViewController,
//              let tabBarController = hostingController.children.first as? UITabBarController,
//              let navigationController = tabBarController.selectedViewController as? UINavigationController,
//              let pageViewController = navigationController.topViewController?.children.first as? UIPageViewController else {
//            return
//        }
//        
//        pageViewController.navigationOrientation = .vertical
//    }
}

#Preview {
    ContentView()
}
