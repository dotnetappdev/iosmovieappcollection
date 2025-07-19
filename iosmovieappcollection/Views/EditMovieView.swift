//
//  EditMovieView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct EditMovieView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var year: String
    @State private var director: String
    @State private var genre: String
    @State private var plot: String
    @State private var isWanted: Bool
    @State private var userRating: Int
    
    init(movie: Movie) {
        self.movie = movie
        _title = State(initialValue: movie.title)
        _year = State(initialValue: movie.year != nil ? String(movie.year!) : "")
        _director = State(initialValue: movie.director ?? "")
        _genre = State(initialValue: movie.genre ?? "")
        _plot = State(initialValue: movie.plot ?? "")
        _isWanted = State(initialValue: movie.isWanted)
        _userRating = State(initialValue: movie.userRating ?? 5)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Movie Title", text: $title)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                    TextField("Director", text: $director)
                    TextField("Genre", text: $genre)
                }
                
                Section("Description") {
                    TextField("Plot", text: $plot, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Personal Details") {
                    Toggle("Add to Wishlist", isOn: $isWanted)
                    
                    HStack {
                        Text("Rating")
                        Spacer()
                        Picker("Rating", selection: $userRating) {
                            ForEach(1...10, id: \.self) { rating in
                                Text("\(rating)")
                                    .tag(rating)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section("Metadata") {
                    if let imdbID = movie.imdbID, !imdbID.isEmpty {
                        HStack {
                            Text("IMDB ID")
                            Spacer()
                            Text(imdbID)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let barcode = movie.barcode, !barcode.isEmpty {
                        HStack {
                            Text("Barcode")
                            Spacer()
                            Text(barcode)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Date Added")
                        Spacer()
                        Text(movie.dateAdded, format: .dateTime.day().month().year())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        movie.title = title
        movie.year = Int(year)
        movie.director = director.isEmpty ? nil : director
        movie.genre = genre.isEmpty ? nil : genre
        movie.plot = plot.isEmpty ? nil : plot
        movie.isWanted = isWanted
        movie.userRating = userRating
        
        dismiss()
    }
}

struct EditMovieView_Previews: PreviewProvider {
    static var previews: some View {
        EditMovieView(movie: Movie(
            title: "The Matrix",
            year: 1999,
            director: "The Wachowskis",
            genre: "Action, Sci-Fi",
            userRating: 9
        ))
    }
}