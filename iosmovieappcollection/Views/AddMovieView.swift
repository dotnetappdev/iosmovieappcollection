//
//  AddMovieView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct AddMovieView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var title = ""
    @State private var year = ""
    @State private var director = ""
    @State private var genre = ""
    @State private var plot = ""
    @State private var isWanted = false
    @State private var userRating: Int = 5
    
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
                
                if !appSettings.isAPIConfigured {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Configure IMDB API in Settings to auto-fetch movie details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Movie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMovie()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveMovie() {
        let movie = Movie(
            title: title,
            year: Int(year),
            director: director.isEmpty ? nil : director,
            plot: plot.isEmpty ? nil : plot,
            genre: genre.isEmpty ? nil : genre,
            isWanted: isWanted,
            userRating: userRating
        )
        
        modelContext.insert(movie)
        dismiss()
    }
}

struct AddMovieView_Previews: PreviewProvider {
    static var previews: some View {
        AddMovieView()
            .environmentObject(AppSettings())
    }
}