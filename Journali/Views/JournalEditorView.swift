//
//  JournalEditorView.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI

struct JournalEditorView: View {
    @ObservedObject var viewModel: JournalViewModel

    let journalToEdit: Journal?
    // علامة الاستفهام تعني انها ممكن تكون فاضية
    // اذا كانت فاضية فهي يومية جديدة واذا لا ف احنا قاعدين نعدل

    @Environment(\.dismiss) private var dismiss
    // اداة من النظام تغلق هذه النافذة عند استدعاء dismiss

    @State private var title: String
    @State private var text: String
    // State يعني اذا تغيرت القيمة تتحدث الشاشة تلقائياو private يعني ان القيمة لهذه الصفحة فقط

    @State private var showDiscardDialog = false
    // صح او خطأ يحدد هل تظهر رسالة التخلص من التغييرات

    @FocusState private var isTitleFocused: Bool
    // يتذكر هل المؤشر والكيبورد داخل خانة العنوان
    // نستخدمه لفتح الكيبورد تلقائيا عند يومية جديدة

    init(viewModel: JournalViewModel, journalToEdit: Journal? = nil) {
        // init يشتغل مرة واحدة عند انشاء الصفحة
        // كلمة nil بعد علامة المساواة تعني انه اذا ماعطيناه يومية فهي يومية جديدة

        self.viewModel = viewModel
        self.journalToEdit = journalToEdit
        _title = State(initialValue: journalToEdit?.title ?? "")
        _text = State(initialValue: journalToEdit?.text ?? "")
        // علامتا الاستفهام المتتاليتان تعني اذا فيه قيمة خذها واذا لا خذ نصا فاضيا
        // النتيجة ان الخانات فاضية في اليومية الجديدة وممتلئة عند التعديل
       }

    private var hasChanges: Bool {
        title != (journalToEdit?.title ?? "") || text != (journalToEdit?.text ?? "")
    }
    // هل غير المستخدم شيئا
    // يقارن العنوان والنص الحاليين مع الاصليين
    // نستخدمه لنقرر هل نسأل المستخدم قبل الاغلاق

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // يرجع صح فقط اذا العنوان فيه حرف واحد على الاقل بعد حذف المسافات

    private var dateText: String {
        Journal.format(journalToEdit?.date ?? Date())
    }
    // عند التعديل نعرض تاريخ اليومية وعند الاضافة نعرض تاريخ اليوم

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: X on the left, ✓ on the right
            HStack {

                Button {
                    if hasChanges {
                        showDiscardDialog = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle().stroke(Color.appTextSecondary.opacity(0.4), lineWidth: 1)
                        }
                }

                Spacer()

                Button {
                    saveJournal()
                    // يستدعي دالة saveJournal الموجودة في اخر الملف
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appBackground)
                        .frame(width: 40, height: 40)
                        .background(Color.appAccent, in: Circle())
                }
                .disabled(!canSave)
                // الزر مايشتغل اذا العنوان فاضي
                .opacity(canSave ? 1 : 0.4)
            }
            .padding(.bottom, 24)

            TextField(
                "",
                text: $title,
                // علامة الدولار تعني ربط في الاتجاهين
                prompt: Text("Title").foregroundStyle(Color.appTextSecondary.opacity(0.5))
            )
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Color.appTextPrimary)
            .focused($isTitleFocused)

            Text(dateText)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 6)

            // Journal text, with a placeholder shown while it is empty
            ZStack(alignment: .topLeading) {

                TextEditor(text: $text)
                    // TextEditor خانة كتابة كبيرة متعددة الاسطر
                    // وليس فيها كلمة باهتة جاهزة لذلك صنعناها بانفسنا
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color.appTextPrimary)
                    .scrollContentBackground(.hidden)
                    // يخفي الخلفية الافتراضية للخانة
                    .scrollDismissesKeyboard(.interactively)
                    // الكيبورد يختفي عند التمرير
                    .padding(.horizontal, -5)
                    // مسافة سالبة تلغي المسافة الجاهزة داخل الخانة

                if text.isEmpty {
                    Text("Type your Journal...")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(Color.appTextSecondary.opacity(0.5))
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
            .padding(.top, 20)
        }
        .padding(20)
        .tint(Color.appAccent)
        .presentationBackground(Color.appCard)
        .presentationDragIndicator(.visible)
        .confirmationDialog(
            "Are you sure you want to discard changes on this journal?",
            isPresented: $showDiscardDialog,
            titleVisibility: .visible
        ) {
       

            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing") { }
        }
        .onAppear {
            // onAppear يشتغل عند ظهور الصفحة
            if journalToEdit == nil {
                isTitleFocused = true
                // اذا يومية جديدة نضع المؤشر في العنوان ليفتح الكيبورد مباشرة
            }
        }
    }

    private func saveJournal() {
        // دالة الحفظ
        // الصفحة لا تحفظ الملف بنفسها بل تطلب من ViewModel

        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // العنوان بعد حذف المسافات الزائدة من اوله واخره

        if let journal = journalToEdit {
            // if let طريقة امنة لفتح القيمة التي لها علامة استفهام
            // اذا فيه يومية فنحن نعدل
            if hasChanges {
                viewModel.update(journal, title: cleanTitle, text: text)
                // نستدعي update فقط اذا فيه تغيير
            }
        } else {
            viewModel.add(title: cleanTitle, text: text)
            // ما فيه يومية يعني يومية جديدة فنستدعي add
        }
        dismiss()
    }
}

#Preview {
    JournalEditorView(viewModel: JournalViewModel())
        .preferredColorScheme(.dark)

}
