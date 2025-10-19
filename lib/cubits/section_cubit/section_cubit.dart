import 'package:el_doctor/cubits/section_cubit/section_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/sections_model.dart';
import '../../data/my_dataBase.dart';

class SectionCubit extends Cubit<SectionState> {
  SectionCubit() : super(SectionInitial());

  Future<void> addSection(String name, bool isIncome) async {
    emit(SectionLoading());
    try {
      await MyDatabase.addSections(
        SectionsModel(name: name, isIncome: isIncome),
      );
      emit(SectionSuccess());
      getSections();
    } catch (e) {
      emit(SectionError("حدث خطأ أثناء الحفظ"));
    }
  }

  void getSections() {
    emit(SectionLoading());
    MyDatabase.getSectionsRealTimeUpdate().listen(
      (snapshot) {
        final sections = snapshot.docs.map((e) => e.data()).toList();
        emit(SectionLoaded(sections));
      },
      onError: (error) {
        emit(SectionError("حدث خطأ أثناء جلب البيانات"));
      },
    );
  }
}
