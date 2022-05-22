import 'package:clean_architecture/core/network/network_info.dart';
import 'package:clean_architecture/core/utils/input_converter.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/impl/number_trivia_remote_data_source_impl.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture/features/number_trivia/presentation/pages/home.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'features/number_trivia/data/datasources/impl/number_trivia_local_data_source_impl.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/blocs/bloc/number_trivia_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  NumberTriviaRepositoryImpl _getRepo() {
    return NumberTriviaRepositoryImpl(
      localDataSource: NumberTriviaDataSourceImpl(null),
      remoteDataSource: NumberTriviaRemoteDataSourceImpl(http.Client()),
      networkInfo: NetworkInfoImpl(
        DataConnectionChecker(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NumberTriviaBloc(
        getConcreteNumberTrivia: GetConcreteNumberTrivia(
          _getRepo(),
        ),
        getRandomNumberTrivia: GetRandomNumberTrivia(
          _getRepo(),
        ),
        inputConverter: InputConverter(),
      ),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home(),
      ),
    );
  }
}
