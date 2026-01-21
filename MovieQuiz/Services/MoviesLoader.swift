import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var mostPopularMoviesUrl: URL? {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            print("Unable to construct mostPopularMoviesUrl")
            return nil
        }
        return url
    }
    private let jsonDecoder = JSONDecoder()
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, any Error>) -> Void) {
        guard let url = mostPopularMoviesUrl else {
            let error = NSError(domain: "NetworkError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Не удалось сформировать URL для загрузки данных"]
            )
            handler(.failure(error))
            return
        }
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try jsonDecoder.decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
