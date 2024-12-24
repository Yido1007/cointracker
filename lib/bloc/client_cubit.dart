import 'package:flutter_bloc/flutter_bloc.dart';

part 'client_state.dart';

class ClientCubit extends Cubit<ClientState> {
  ClientCubit(super.initialState);
  // Change Language state
  changeLanguage({required String language}) {
    final newState = ClientState(
      language: language,
    );

    emit(newState);
  }

  // Change darkMode state
  changeDarkMode({required bool darkMode}) {
    final newState = ClientState(
      language: state.language,
    );
    emit(newState);
  }
}
