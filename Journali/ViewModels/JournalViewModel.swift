//
//  JournalViewModel.swift
//  Journali
//
//  Created by Waad AlMalki on 09/11/2026.
//

import SwiftUI
import Combine

// The two ways the list can be sorted.
enum SortOption {
    // enum هي قائمة خيارات ثابتة ولا يوجد غيرها
    // الترتيب عندنا له خياران فقط
    //  entryDate و bookmark يعني الترتيب حسب التاريخ
    // استخدمنا enum بدل كلمات عادية حتى تنبهنا سويفت اذا أخطأنا في الكتابة
    case entryDate
    case bookmark
}

// The "brain" of the app: it holds all journals and the logic to change them.
class JournalViewModel: ObservableObject {

    // فيه كل المنطق مثل الاضافة والتعديل والحذف والبحث والترتيب والحفظ
    // الشاشات فقط تطلب منه وهو الذي ينفذ
    // استخدمنا class وليس struct لان اليوميات مشتركة بين اكثر من شاشة
    // كل الشاشات تستخدم نفس النسخة وترى نفس اليوميات
    // ObservableObject يعني ان الشاشات تقدر تراقب هذا المدير

    @Published var journals: [Journal] = []
    // قائمة كل اليوميات وتبدأ فاضية
    // Published يعني اي تغيير في القائمة يحدث الشاشات تلقائيا
    // لهذا يظهر الكرت الجديد بعد الحفظ بدون ان نعمل شيء

    @Published var searchText = ""
    // النص الذي يكتبه المستخدم في خانة البحث ويبدأ فاضي

    @Published var sortOption: SortOption = .entryDate
    // نوع الترتيب الحالي والبداية حسب التاريخ الاحدث اولا

    private let fileURL: URL
    // مكان ملف الحفظ على الجوال
    // private يعني ان هذا الكلاس فقط يستخدمه
    // let يعني انه لا يتغير ابدا

    init() {
        // init يشتغل مرة واحدة عند انشاء المدير
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // نطلب من الجوال مجلد Documents وهو مجلد خاص بالتطبيق وتبقى فيه الملفات بعد اغلاق التطبيق
        // الصفر لاننا ناخذ اول مجلد من القائمة

        fileURL = folder.appendingPathComponent("journals.json")
        // نضيف لمكان المجلد اسم الملف وهو ملف json اسمه journals

        load()
        // نقرأ اليوميات المحفوظة حتى تظهر عند فتح التطبيق
    }

    // The journals the screen should show: searched, then sorted.
    var displayedJournals: [Journal] {
        // هذه اليوميات التي تظهر في الشاشة بعد البحث ثم الترتيب
        // هذه قيمة محسوبة تتحسب كل مرة نحتاجها
        // لا تغير القائمة الاصلية بل تشتغل على نسخة منها

        var result = journals
        // ننسخ القائمة ونشتغل على النسخة

        if !searchText.isEmpty {
            // يعني اذا المستخدم كتب شيئا في البحث نفلتر القائمة

            result = result.filter { journal in
                // filter تبقي فقط اليوميات التي تنجح في الشرط
                journal.title.localizedCaseInsensitiveContains(searchText) ||
                journal.text.localizedCaseInsensitiveContains(searchText)
                // localizedCaseInsensitiveContains تعني يحتوي على الكلمة بدون الاهتمام بالحروف الكبيرة والصغيرة
                // الخطان العموديان تعني او
            }
        }

        switch sortOption {
        // switch تختار الكود المناسب حسب نوع الترتيب
        // وسويفت تتأكد اننا كتبنا كل الخيارات

        case .entryDate:
            result.sort { $0.date > $1.date }
            // الاول والثاني هما يوميتان تتم المقارنة بينهما
            // الاكبر تاريخا هي الاحدث وتأتي اولا

        case .bookmark:
            // ترتيب المفضلة
            result.sort { first, second in
                // first و second هما اليوميتان اللتان نقارن بينهما
                if first.isBookmarked != second.isBookmarked {
                    return first.isBookmarked
                }
                return first.date > second.date
                // اذا الاثنتان لهما نفس الحالة فالاحدث تأتي اولا
            }
        }

        return result
        // نرجع القائمة النهائية للشاشة
    }

    func add(title: String, text: String) {
        // دالة اضافة يومية جديدة
        let newJournal = Journal(title: title, text: text, date: Date())
        // ننشئ يومية بالعنوان والنص وتاريخ الان وهو Date

        journals.append(newJournal)
        // append تضيف اليومية في اخر القائمة
        // والشاشة تتحدث لان القائمة Published

        save()
        // نحفظ حتى لا تضيع اليومية
    }

    func update(_ journal: Journal, title: String, text: String) {
        // دالة تعديل يومية موجودة
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else { return }
        // firstIndex تبحث عن مكان اليومية في القائمة بواسطة id
        // نستخدم id وليس العنوان لان العناوين ممكن تتكرر
        // guard let تعني اذا ما لقينا اليومية نوقف الدالة بدون ان يتعطل التطبيق

        journals[index].title = title
        journals[index].text = text
        // نغير العنوان والنص في مكان اليومية

        journals[index].date = Date()
        // نحدث التاريخ الى تاريخ الان لان التاريخ يتغير عند التعديل

        save()
    }

    func delete(_ journal: Journal) {
        // دالة حذف يومية
        journals.removeAll { $0.id == journal.id }
        // removeAll تحذف كل يومية يطابق id تبعها اليومية المطلوبة

        save()
    }

    func toggleBookmark(_ journal: Journal) {
        // دالة تفعيل او الغاء المفضلة
        guard let index = journals.firstIndex(where: { $0.id == journal.id }) else { return }
        // نبحث عن مكان اليومية وان ما لقيناها نوقف الدالة

        journals[index].isBookmarked.toggle()
        // toggle تقلب القيمة
        // من صح الى خطأ او من خطأ الى صح

        save()
        // نحفظ
    }

    // Saving and loading: journals are stored in a small file on the phone.
    private func save() {
        // دالة الحفظ
        // private يعني ان الشاشات لا تستدعيها مباشرة
        // بل تستخدم دوال مثل add و update وهي التي تستدعي الحفظ

        do {
            // do و catch معناهما نجرب الحفظ
            // واذا فشل نتعامل مع الخطأ بدل ان يتوقف التطبيق

            let data = try JSONEncoder().encode(journals)
            // JSONEncoder تحول قائمة اليوميات الى نص json
            // وهذا ممكن لان Journal من نوع Codable
            // كلمة try تعني ان هذا السطر ممكن يفشل

            try data.write(to: fileURL, options: .atomic)
            // write تكتب البيانات في الملف
            // atomic تعني انها تكتب اولا في ملف مؤقت ثم تبدله بالملف الحقيقي
            // حتى لو توقف التطبيق في النص لا يخرب الملف
        } catch {
            print("Could not save journals: \(error)")
            // اذا فشل الحفظ نطبع سبب الخطأ للمطور
        }
    }

    private func load() {
        // دالة القراءة وتشتغل عند فتح التطبيق
        guard let data = try? Data(contentsOf: fileURL) else { return }
        // try مع علامة الاستفهام تعني نحاول نقرأ الملف واذا فشلنا ناخذ قيمة فاضية بدون خطأ
        // guard let تعني اذا ما فيه ملف مثل اول مرة يفتح التطبيق نوقف الدالة
        // وتبقى القائمة فاضية فتظهر الصفحة الفاضية

        if let savedJournals = try? JSONDecoder().decode([Journal].self, from: data) {
            // JSONDecoder تحول نص json مرة ثانية الى يوميات
            // الجزء Journal مع المصفوفة يخبرها بنوع الشيء الذي تبنيه

            journals = savedJournals
        }
    }
}
