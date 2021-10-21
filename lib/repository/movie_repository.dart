import 'package:ble_project/base/dio_new.dart';
import 'package:ble_project/repository/movie_api_provider.dart';

class MovieRepository {
  final moviesApiProvider = MovieApiProvider();

  Future<HttpResponse> fetchHome() => moviesApiProvider.getHome();

  Future<HttpResponse> fetchMovies(String type) => moviesApiProvider.getMovie(type);

  Future<HttpResponse> fetchRanking(String type) => moviesApiProvider.getRanking(type);

  Future<HttpResponse> fetchSearchSuggestions(String keyword) => moviesApiProvider.getSearchSuggestions(keyword);

  Future<HttpResponse> fetchSearchResultByPage(String keyword, String page) => moviesApiProvider.getSearchResultByPage(keyword, page);

  Future<HttpResponse> fetchMovieDetail(String movieId) => moviesApiProvider.getMovieDetail(movieId);

  Future<HttpResponse> fetchAllFilter() => moviesApiProvider.getAllFilters();

  Future<HttpResponse> fetchMoreData(int type, int page) => moviesApiProvider.getMoreData(type, page);
}