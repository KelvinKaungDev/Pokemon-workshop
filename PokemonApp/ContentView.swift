

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI

struct PokemonModel: Decodable {
    var results: [Results]
}

struct Results: Decodable, Hashable {
    var name: String
    var url: String
}

struct PokemonViewModel {
    
    static var shared = PokemonViewModel()
    
    func fetchData(completion: @escaping ([Results]) -> ()) {
        if let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let safeData = data {
                    do {
                        let result = try JSONDecoder().decode(PokemonModel.self, from: safeData)
                        DispatchQueue.main.async {
                            completion(result.results)
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }.resume()
        }
    }
 }

struct PokemonSpriteModel: Decodable {
    var sprites: Sprites
}

struct Sprites: Decodable {
    var back_default: String
}

struct PokemonSpriteViewModel {
    static var shared = PokemonSpriteViewModel()
    
    func fetchData(url: String,completion: @escaping (Sprites) -> ()) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let safeData = data {
                    do {
                        print("HelloOne")
                        let result = try JSONDecoder().decode(PokemonSpriteModel.self, from: safeData)
                        DispatchQueue.main.async {
                            completion(result.sprites)
                            print("helloTwo")
                        }
                        print("HelloThree")
                    } catch {
                        print(error)
                    }
                    
                }
            }.resume()
        }
    }
}

struct PokemonSpriteView : View {
    var urlImage = ""
    @State var image: String = ""
    var body: some View {
        VStack {
            WebImage(url: URL(string: image))
        }.onAppear {
            PokemonSpriteViewModel.shared.fetchData(url: urlImage) { result in
                self.image = result.back_default
            }
        }
    }
}

struct ContentView: View {
    var names = ["Hello", "World"]
    @State var results = [Results]()
    @State private var searchText = ""
    
    var filterResults: [Results] {
        if searchText.isEmpty {
            return results
        } else {
            return results.filter { result in
                return result.name.contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filterResults, id: \.self) { result in
                HStack {
                    PokemonSpriteView(urlImage: result.url)
                    Text(result.name)
                }
            }
            .searchable(text: $searchText)
            .onAppear {
                PokemonViewModel.shared.fetchData { results in
                    self.results = results
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
