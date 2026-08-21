import SwiftData
import SwiftUI

struct AddCatStepperView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddCatViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            StepperIndicator(
                currentStep: viewModel.currentStep,
                totalSteps: AddCatViewModel.totalSteps,
                stepTitles: AddCatViewModel.stepTitles
            )
            .padding(.vertical, AppTheme.Spacing.md)

            Divider()

            if viewModel.isSaved {
                successView
            } else {
                stepContent
            }

            Spacer()

            if !viewModel.isSaved {
                navigationButtons
                    .padding(AppTheme.Spacing.md)
            }
        }
        .navigationTitle("Add Cat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.breedsState {
                viewModel.fetchBreeds()
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 0:
            AddCatBasicInfoView(viewModel: viewModel)
        case 1:
            AddCatDetailsView(viewModel: viewModel)
        case 2:
            AddCatReviewView(
                viewModel: viewModel,
                onSave: {
                    viewModel.save(context: modelContext)
                })
        default:
            EmptyView()
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            if viewModel.currentStep > 0 {
                AppButton(title: "Back", style: .secondary) {
                    viewModel.goBack()
                }
            }

            if viewModel.currentStep < AddCatViewModel.totalSteps - 1 {
                AppButton(title: "Next") {
                    _ = viewModel.validateAndAdvance()
                }
            }
        }
    }

    private var successView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.success)

            Text("Cat Registered!")
                .font(AppTheme.Fonts.title)
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text("Your cat has been saved successfully.")
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: AppTheme.Spacing.sm) {
                AppButton(title: "Register Another") {
                    viewModel.reset()
                }

                AppButton(title: "Done", style: .secondary) {
                    selectedTab = 1
                    viewModel.reset()
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.bottom, AppTheme.Spacing.md)
        }
    }
}

#Preview{
    NavigationStack {
        AddCatStepperView(selectedTab: .constant(2))
    }
    .modelContainer(for: RegisteredCat.self, inMemory: true)
}
