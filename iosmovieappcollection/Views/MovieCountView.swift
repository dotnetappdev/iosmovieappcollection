//
//  MovieCountView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI
import SwiftData

struct MovieCountView: View {
    @Query private var movies: [Movie]
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "film.fill")
                .font(.caption)
            Text("\(movies.count)")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.secondary)
    }
}

struct MovieCountView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCountView()
    }
}