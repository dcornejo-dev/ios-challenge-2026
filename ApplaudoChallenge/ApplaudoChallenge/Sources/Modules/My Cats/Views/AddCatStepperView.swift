import SwiftData
import SwiftUI

struct AddCatStepperView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AddCatViewModel()
    @State private var showDiscardAlert = false
    @State private var forwardDirection = true

    var body: some View {
        Group {
            if viewModel.isSaved {
                AddCatSuccessView(catName: viewModel.name) { dismiss() }
                    .transition(.opacity)
            } else {
                stepperContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSaved)
        .presentationDetents([.large])
        .interactiveDismissDisabled(viewModel.hasUnsavedData || viewModel.isSaved)
    }

    private var stepperContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                StepDashesIndicator(
                    totalSteps: AddCatViewModel.totalSteps,
                    currentStep: viewModel.currentStep
                )
                .padding(.top, AppTheme.Spacing.md)
                .padding(.horizontal, AppTheme.Spacing.md)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        stepHeader
                        stepContent
                            .id(viewModel.currentStep)
                            .transition(stepTransition)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)

                bottomBar
            }
            .background(AppTheme.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leadingChrome
                }
            }
            .alert("Discard registration?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your progress will be lost.")
            }
        }
    }

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: forwardDirection ? .trailing : .leading),
            removal: .move(edge: forwardDirection ? .leading : .trailing)
        )
    }

    @ViewBuilder
    private var leadingChrome: some View {
        if viewModel.currentStep == 0 {
            Button {
                if viewModel.hasUnsavedData {
                    showDiscardAlert = true
                } else {
                    dismiss()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .accessibilityLabel("Close")
        } else {
            Button {
                forwardDirection = false
                viewModel.goBack()
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Back")
                        .font(AppTheme.Fonts.body)
                }
                .foregroundColor(AppTheme.Colors.textPrimary)
            }
            .accessibilityLabel("Back")
        }
    }

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text(headerTitle)
                .font(AppTheme.Fonts.largeTitle)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(headerSubtitle)
                .font(AppTheme.Fonts.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 0:
            AddCatIdentityStep(viewModel: viewModel)
        case 1:
            AddCatDetailsStep(viewModel: viewModel)
        case 2:
            AddCatPhotoStep(viewModel: viewModel)
        default:
            EmptyView()
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            AppButton(title: ctaTitle) {
                handleCTA()
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.md)
        }
        .background(AppTheme.Colors.background)
    }

    private func handleCTA() {
        switch viewModel.currentStep {
        case 0, 1:
            forwardDirection = true
            _ = viewModel.validateAndAdvance()
        case 2:
            guard viewModel.canSave else {
                forwardDirection = false
                viewModel.jumpToFirstInvalidStep()
                return
            }
            viewModel.save(context: modelContext)
        default:
            break
        }
    }

    private var headerTitle: String {
        switch viewModel.currentStep {
        case 0: return "Name and breed"
        case 1: return "Tell us more"
        case 2: return "Add a photo"
        default: return ""
        }
    }

    private var headerSubtitle: String {
        switch viewModel.currentStep {
        case 0: return "Give your cat a name and pick their breed."
        case 1: return "Add age, appearance, and a short description of your cat."
        case 2: return "Optional — you can skip this and register anyway."
        default: return ""
        }
    }

    private var ctaTitle: String {
        viewModel.currentStep == AddCatViewModel.totalSteps - 1 ? "Register" : "Continue"
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddCatStepperView()
        }
}
