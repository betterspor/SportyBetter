//
//  Onboarding.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPageIndex = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "dumbbell.fill",
            title: "Welcome to SportyBetter",
            description: "Your ultimate companion for tracking workouts, monitoring progress, and achieving your fitness goals."
        ),
        OnboardingPage(
            iconName: "list.clipboard.fill",
            title: "Log Every Lift",
            description: "Easily track your exercises, sets, reps, and weight. See your history and watch your strength grow."
        ),
        OnboardingPage(
            iconName: "ruler.fill",
            title: "Track Your Measurements",
            description: "Keep a detailed log of your body measurements to see physical changes alongside your performance."
        ),
        OnboardingPage(
            iconName: "chart.bar.xaxis",
            title: "Visualize Your Progress",
            description: "Dive into detailed charts and analytics. Track your total volume, BMI, and progression for key exercises."
        )
    ]

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPageIndex.animation(.easeInOut)) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 20) {
                    PageIndicatorView(pageCount: pages.count, currentIndex: $currentPageIndex)
                    
                    OnboardingButton(isLastPage: currentPageIndex == pages.count - 1) {
                        if currentPageIndex < pages.count - 1 {
                            currentPageIndex += 1
                        } else {
                            dismiss()
                        }
                    }
                }
                .padding(30)
            }
        }
    }
}


private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle().fill(Color.themeCardBackground).frame(width: 150, height: 150)
                Image(systemName: page.iconName)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.themeAccentRed)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle).bold()
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.themeSecondaryText)
            }
            .multilineTextAlignment(.center)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 30)
            
            Spacer()
        }
        .padding(40)
        .foregroundColor(.themePrimaryText)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0)) {
                isAnimating = true
            }
        }
    }
}

private struct PageIndicatorView: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.themeAccentRed : Color.themeCardBackground)
                    .frame(width: index == currentIndex ? 30 : 10, height: 10)
            }
        }
    }
}

private struct OnboardingButton: View {
    let isLastPage: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(isLastPage ? "Get Started" : "Continue")
                .font(.headline.bold())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeAccentRed)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    OnboardingView()
}
