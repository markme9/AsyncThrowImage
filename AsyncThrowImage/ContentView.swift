//
//  ContentView.swift
//  AsyncThrowImage
//
//  Created by zoya me on 10/30/22.
//

import SwiftUI

class AsyncThrowImage {
    
    var image: UIImage? = nil
    let url = URL(string: "https://picsum.photos/200/300")!
    
    // By using asynchronous
    
    func responseHandler(data: Data? , response: URLResponse?) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response else { return nil}
        return image
    }
    
    func loadImageWithAsync() async throws -> UIImage? {
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return responseHandler(data: data, response: response)
        } catch  {
            throw error
        }
    }
    
    // Here is another way to call API by completion
    
    func getImageWithCompletion(completionHandeler: @escaping(_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard
                let data = data,
                let image = UIImage(data: data),
                let _ = response else { return }
            completionHandeler(image, nil)
        }
        .resume()
    }
}

class ViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    
    var loader = AsyncThrowImage()
    
    func fetchImage() async {
        let image = try? await loader.loadImageWithAsync()
        self.image = image
    }
    
    func fetchImageWithCompletion() {
        loader.getImageWithCompletion { [weak self] image, error in
            self?.image = image
        }
    }
}

struct ContentView: View {
    
    @StateObject var vm = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 350)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 10)
                }
            }
            .onAppear {
                //Task {
                    vm.fetchImageWithCompletion()
                //}
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        //Task {
                            vm.fetchImageWithCompletion()
                        //}
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3.bold())
                    }

                }
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
